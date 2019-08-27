package api

import (
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"

	"github.com/dgraph-io/dgo/protos/api"
	"github.com/pkg/errors"
)

func (rt *Router) loginHandler(w http.ResponseWriter, r *http.Request) {
	var back []byte
	var err error

	defer func() {
		_, err = w.Write(back)
		if err != nil {
			panic(err)
		}
	}()

	if r.Method == "GET" {
		sessid := rt.NewSessid()

		sess := &session{online: false}

		var _salt [8]byte
		binary.BigEndian.PutUint64(_salt[:], uint64(time.Now().Unix()))
		sess.salt = hex.EncodeToString(_salt[:])

		rt.sesspool.Set(sessid, sess)

		go func() {
			timer := time.NewTimer(time.Second * time.Duration(rt.cfg.sessid_timeout))
			<-timer.C
			if !sess.online {
				rt.sesspool.Remove(sessid)
			}
		}()

		http.SetCookie(w, &http.Cookie{
			Name:   "sessionid",
			Value:  sessid,
			MaxAge: rt.cfg.sessid_timeout,
		})

		back, err = json.Marshal(callback{
			Success: "200",
			Error:   "",
			Data: strStrMap{
				"salt": sess.salt,
			},
		})
		if err != nil {
			panic(err)
		}
		return
	}

	var sess *session
	var sessid *http.Cookie
	sessid, sess, back = checkSession(rt, r)
	if sessid != nil && len(back) != 0 {
		return
	}

	if sess.online {
		back = RetAlreadyLogined
		rt.infof("%s\n", back)
		return
	}

	pb := strAnyMap{}
	body, _ := ioutil.ReadAll(r.Body)
	err = json.Unmarshal(body, &pb)
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		back = RetInvalid
		return
	}
	p := strstrmap(pb)

	if l1, l2 := len(p["name"]), len(p["passwd"]); l1 < rt.cfg.username_minlen ||
		l2 != PASSWORD_LEN {
		r := callback{
			Success: "400",
			Error:   fmt.Sprintf("name(%d) or passwd(%d) too short", l1, l2),
			Data:    nil,
		}

		back, err = json.Marshal(r)
		if err != nil {
			panic(err)
		}

		rt.infof("%s\n", back)
		return
	}

	back = checkEscape(p["name"])
	if len(back) != 0 {
		return
	}

	resjson, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ exist(func: has(isuser)) @filter(eq(email, \"%s\") OR eq(phone, \"%s\") OR eq(username, \"%s\")) { uid, passwd, sessid } }", p["name"], p["name"], p["name"]))
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		back = RetNotAvailable
		return
	}

	res := struct {
		Exist []struct {
			Uid    string `json:"uid"`
			Passwd string `json:"passwd"`
			Sessid string `json:"sessid"`
		} `json:"exist"`
	}{}

	err = json.Unmarshal(resjson.Json, &res)
	if err != nil {
		panic(err)
	}

	if len(res.Exist) == 0 {
		back = RetNoSuchUser
		rt.infof("%s\n", back)
		return
	}

	passwd := res.Exist[0].Passwd
	uid := res.Exist[0].Uid
	sessval := res.Exist[0].Sessid

	var exceptpasswd string
	{
		l1 := len(sess.salt)
		l2 := len(passwd)
		l3 := len(sessid.Value)

		passwordbytes := make([]byte, l1+l2+l3)
		copy(passwordbytes, sess.salt)
		copy(passwordbytes[l1:], passwd)
		copy(passwordbytes[l1+l2:], sessid.Value)
		p := sha256.Sum256(passwordbytes)
		exceptpasswd = hex.EncodeToString(p[:])
	}

	if exceptpasswd != p["passwd"] {
		back = RetIncorrectPasswd
		rt.infof("%s\n", back)
		return
	}

	if len(sessval) != 0 {
		rt.sesspool.Remove(sessid.Value)
		sessid.Value = sessval
	} else {
		_, err = rt.dio.NewTxn().Mutate(rt.ctx, &api.Mutation{
			CommitNow: true,
			Set: []*api.NQuad{
				&api.NQuad{
					Subject:   uid,
					Predicate: "online",
					ObjectValue: &api.Value{
						Val: &api.Value_StrVal{
							StrVal: sessid.Value,
						},
					},
				},
			},
		})
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			back = RetNotAvailable
			return
		}
	}

	sess.online = true
	sess.uid = res.Exist[0].Uid
	rt.sesspool.Set(sessid.Value, sess)

	sessid.MaxAge = rt.cfg.login_defage
	http.SetCookie(w, sessid)

	back = RetSuccess
}
