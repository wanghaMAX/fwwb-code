package api

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"regexp"
	"sync"

	vision "cloud.google.com/go/vision/apiv1"
	"github.com/dgraph-io/dgo"
	"github.com/dgraph-io/dgo/protos/api"
	"github.com/go-ego/riot"
	"github.com/go-ego/riot/types"
	cmap "github.com/orcaman/concurrent-map"
	"github.com/pkg/errors"
	"google.golang.org/api/option"
	"google.golang.org/grpc"

	_ "github.com/mattn/go-sqlite3"
)

const (
	USERINFO_OTHERS userinfo_usertype = iota
	USERINFO_FRIEND
	USERINFO_SELF

	USERINFO_UID uint = iota * 2
	USERINFO_AVATAR
	USERINFO_USERNAME
	USERINFO_SEX
	USERINFO_EMAIL
	USERINFO_PHONE
	USERINFO_BIRTHDAY
	USERINFO_CITY
	USERINFO_STATS

	PASSWORD_LEN = sha256.Size * 2
	AVATAR_LEN   = sha256.Size * 2
)

type userinfo_usertype = int64

type callback struct {
	Success string      `json:"success"`
	Error   string      `json:"error"`
	Data    interface{} `json:"data"`
}

type session struct {
	online bool
	uid    string
	salt   string
}

type config struct {
	image_path            string
	search_path           string
	dgraph                string
	username_minlen       int
	login_defage          int
	sessid_timeout        int
	content_maxlen        int
	cover_maxlen          int
	title_maxlen          int
	tag_maxlen            int
	default_privacy       userinfo_usertype
	username_pattern      *regexp.Regexp
	server_maxerr         int
	default_vision_maxres int
	vision_socks5_proxy   string
}

type Router struct {
	cfg      config
	sesspool cmap.ConcurrentMap
	vision   *vision.ImageAnnotatorClient
	dioconn  *grpc.ClientConn
	dio      *dgo.Dgraph
	search   riot.Engine
	ctx      context.Context

	errf   func(string, ...interface{})
	warnf  func(string, ...interface{})
	infof  func(string, ...interface{})
	logger *log.Logger

	errcnt int
	mux    *sync.Mutex
}

func New(opts ...RouterOption) (*Router, error) {
	var err error

	r := &Router{}

	r.mux = &sync.Mutex{}
	r.logger = log.New(os.Stdout, "", log.Ltime)
	r.errf = func(a string, args ...interface{}) {
		r.logger.Printf("ERROR "+a, args...)
	}
	r.warnf = func(a string, args ...interface{}) {
		r.logger.Printf("WARN "+a, args...)
	}
	r.infof = func(a string, args ...interface{}) {
		r.logger.Printf("INFO "+a, args...)
	}

	r.cfg.image_path = "./images"
	r.cfg.search_path = ""
	r.cfg.dgraph = "127.0.0.1:9080"
	r.cfg.username_pattern = regexp.MustCompile("^[A-Za-z0-9_]+$")
	r.cfg.username_minlen = 6
	r.cfg.login_defage = 60 * 24
	r.cfg.sessid_timeout = 180
	r.cfg.content_maxlen = 4096
	r.cfg.cover_maxlen = 128
	r.cfg.title_maxlen = 128
	r.cfg.tag_maxlen = 128
	r.cfg.default_privacy = 0
	r.cfg.server_maxerr = 128
	r.cfg.vision_socks5_proxy = ""
	r.ctx = context.Background()

	for _, opt := range opts {
		if err = opt(r); err != nil {
			r.infof("%s\n", err)
			return nil, err
		}
	}

	err = os.MkdirAll(r.cfg.image_path, 0755)
	if err != nil {
		r.infof("%s\n", err)
		return nil, err
	}

	r.sesspool = cmap.New()

	r.search.Init(types.EngineOpts{
		Using:   1,
		PinYin:  true,
		GseMode: true,
		IndexerOpts: &types.IndexerOpts{
			IndexType: types.FrequenciesIndex,
		},
		UseStore:    len(r.cfg.search_path) != 0,
		StoreFolder: r.cfg.search_path,
		StoreEngine: "bg",
	})

	if len(r.cfg.vision_socks5_proxy) != 0 {
		r.vision, err = vision.NewImageAnnotatorClient(r.ctx, option.WithGRPCDialOption(grpc.WithContextDialer(r.newProxyDialer())))
	} else {
		r.vision, err = vision.NewImageAnnotatorClient(r.ctx)
	}
	if err != nil {
		r.infof("%s\n", err)
		return nil, err
	}

	r.dioconn, err = grpc.Dial(r.cfg.dgraph, grpc.WithInsecure())
	if err != nil {
		r.infof("%s\n", err)
		return nil, err
	}

	r.dio = dgo.NewDgraphClient(api.NewDgraphClient(r.dioconn))

	return r, nil
}

func (rt *Router) ServeHTTP(w http.ResponseWriter, req *http.Request) {
	url := req.URL

	defer func() {
		if e := recover(); e != nil {
			w.Write(RetNotAvailable)

			rt.mux.Lock()
			rt.errcnt++
			rt.mux.Unlock()

			rt.infof("-> %s, %+v\n", url.Path, e)

			if rt.errcnt > rt.cfg.server_maxerr {
				rt.infof("maxerr met\n")
				panic(e)
			}
		}
	}()

	w.Header().Add("Content-Type", "application/json")

	switch url.Path {
	case "/camera":
		rt.cameraHandler(w, req)
	case "/register":
		rt.registerHandler(w, req)
	case "/login":
		rt.loginHandler(w, req)
	case "/updateInfo":
		rt.updateinfoHandler(w, req)
	case "/image":
		rt.imageHandler(w, req)
	case "/userinfo":
		rt.userinfoHandler(w, req)
	case "/follow":
		rt.followHandler(w, req)
	case "/follower":
		rt.followerHandler(w, req)
	case "/subscribe":
		rt.subscribeHandler(w, req)
	case "/pushContent":
		rt.pushContentHandler(w, req)
	case "/getContent":
		rt.getContentHandler(w, req)
	case "/like":
		rt.likeHandler(w, req)
	default:
		w.Write(Ret404)
	}
}

func (rt *Router) NewSessid() string {
	bytes := make([]byte, 16)
	for {
		_, err := rand.Read(bytes)
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}

		str := hex.EncodeToString(bytes)
		if !rt.sesspool.Has(str) {
			rt.infof("new session allocated: %s, already has %d", str, rt.sesspool.Count())
			return str
		}
	}
}

func (rt *Router) DropOffline() {
	for v := range rt.sesspool.IterBuffered() {
		sess := v.Val.(*session)
		if !sess.online {
			rt.sesspool.Remove(v.Key)
		}
	}
}

func (rt *Router) Close() {
	rt.search.Close()
	rt.vision.Close()
	rt.dioconn.Close()
}

func (rt *Router) SetErrorf(e func(string, ...interface{})) {
	rt.errf = e
}

func (rt *Router) SetWarnf(e func(string, ...interface{})) {
	rt.warnf = e
}

func (rt *Router) SetInfof(e func(string, ...interface{})) {
	rt.infof = e
}

func (rt *Router) LoadSchema() (err error) {
	op := &api.Operation{}
	op.Schema = `
		isdoc: bool .
		isad: bool .
		hot: int .
		docid: int @index(int) .
		like: int .
		dislike: int .
		content: string .
		cover: string .
		title: string .
		time: datetime @index(day) .
		tags: [string] @index(term) .
		location: geo @index(geo) .

		isuser: bool .
		push: [uid] @reverse .
		follow: [uid] @reverse .
		avatar: string .
		phone: string @index(exact) .
		email: string @index(exact) .
		username: string @index(exact) .
		passwd: string .
		sex: string .
		birthday: string .
		city: string .
		stats: string .
		sessid: string .
		privacy: int .
	`

	err = rt.dio.Alter(rt.ctx, op)
	return
}

func (rt *Router) RemoveUser(s string) error {
	resjson, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ exist(func: has(isuser)) @filter(eq(email, \"%s\") OR eq(phone, \"%s\") OR eq(username, \"%s\")) @cascade { uid } }", s, s, s))
	if err != nil {
		return err
	}

	res := struct {
		Exist []struct {
			Uid string `json:"uid"`
		} `json:"exist"`
	}{}

	err = json.Unmarshal(resjson.Json, &res)
	if err != nil {
		return err
	}

	mu := &api.Mutation{CommitNow: true}

	for _, v := range res.Exist {
		for _, k := range []string{"isuser", "push", "follow", "avatar", "phone", "email", "username", "passwd", "sex", "birthday", "city", "stats", "sessid", "privacy"} {
			mu.Del = append(mu.Del, &api.NQuad{
				Subject:     v.Uid,
				Predicate:   k,
				ObjectValue: &api.Value{Val: &api.Value_DefaultVal{DefaultVal: "_STAR_ALL"}},
			})
		}
	}

	_, err = rt.dio.NewTxn().Mutate(rt.ctx, mu)
	if err != nil {
		return err
	}

	return nil
}
