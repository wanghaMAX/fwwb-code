package api

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"
	"time"

	"github.com/dgraph-io/dgo/protos/api"
	"github.com/go-ego/riot/types"
	"github.com/pkg/errors"
)

type content struct {
	Cover   string   `json:"cover,emitempty"`
	Title   string   `json:"title,emitempty"`
	Tags    []string `json:"tags,emitempty"`
	X       float64  `json:"x,omitempty"`
	Y       float64  `json:"y,omitempty"`
	Content string   `json:"content,emitempty"`
}

func (rt *Router) pushContentHandler(w http.ResponseWriter, r *http.Request) {
	var back []byte
	var err error

	defer func() {
		_, err = w.Write(back)
		if err != nil {
			panic(err)
		}
	}()

	back = checkMethod(r.Method, "POST")
	if len(back) != 0 {
		return
	}

	var sess *session
	_, sess, back = checkSession(rt, r)
	if len(back) != 0 {
		return
	}

	if !sess.online {
		back = RetNeedPerm
		rt.infof("%s\n", back)
		return
	}

	var v content
	body, _ := ioutil.ReadAll(r.Body)
	err = json.Unmarshal(body, &v)
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		back = RetInvalid
		return
	}

	// TODO: check overflowed
	docid := int64(rt.search.NumIndexed())

	rt.search.Index(strconv.FormatInt(docid, 10), types.DocData{
		Content: v.Content,
		Labels:  v.Tags,
	})

	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		panic(err)
	}

	mu := &api.Mutation{CommitNow: true}

	mu.Set = []*api.NQuad{
		&api.NQuad{
			Subject:   "_:doc",
			Predicate: "isdoc",
			ObjectValue: &api.Value{
				Val: &api.Value_BoolVal{
					BoolVal: true,
				},
			},
		},
		&api.NQuad{
			Subject:   "_:doc",
			Predicate: "docid",
			ObjectValue: &api.Value{
				Val: &api.Value_IntVal{
					IntVal: docid,
				},
			},
		},
		&api.NQuad{
			Subject:   "_:doc",
			Predicate: "like",
			ObjectValue: &api.Value{
				Val: &api.Value_IntVal{
					IntVal: 0,
				},
			},
		},
		&api.NQuad{
			Subject:   "_:doc",
			Predicate: "dislike",
			ObjectValue: &api.Value{
				Val: &api.Value_IntVal{
					IntVal: 0,
				},
			},
		},
		&api.NQuad{
			Subject:   "_:doc",
			Predicate: "hot",
			ObjectValue: &api.Value{
				Val: &api.Value_IntVal{
					IntVal: 0,
				},
			},
		},
		&api.NQuad{
			Subject:   "_:doc",
			Predicate: "content",
			ObjectValue: &api.Value{
				Val: &api.Value_StrVal{
					StrVal: v.Content[:min(rt.cfg.content_maxlen, len(v.Content))],
				},
			},
		},
		&api.NQuad{
			Subject:   "_:doc",
			Predicate: "cover",
			ObjectValue: &api.Value{
				Val: &api.Value_StrVal{
					StrVal: v.Cover[:min(rt.cfg.cover_maxlen, len(v.Cover))],
				},
			},
		},
		&api.NQuad{
			Subject:   "_:doc",
			Predicate: "title",
			ObjectValue: &api.Value{
				Val: &api.Value_StrVal{
					StrVal: v.Title[:min(rt.cfg.title_maxlen, len(v.Title))],
				},
			},
		},
		&api.NQuad{
			Subject:   "_:doc",
			Predicate: "time",
			ObjectValue: &api.Value{
				Val: &api.Value_StrVal{
					StrVal: time.Now().Format("2006-01-02"),
				},
			},
		},
		&api.NQuad{
			Subject:   "_:doc",
			Predicate: "location",
			ObjectValue: &api.Value{
				Val: &api.Value_StrVal{
					StrVal: fmt.Sprintf("{\"type\": \"Point\", \"coordinates\": [%f, %f]}", v.X, v.Y),
				},
			},
		},
		&api.NQuad{
			Subject:   sess.uid,
			Predicate: "push",
			ObjectId:  "_:doc",
		},
	}

	for _, v := range v.Tags {
		mu.Set = append(mu.Set, &api.NQuad{
			Subject:   "_:doc",
			Predicate: "tags",
			ObjectValue: &api.Value{
				Val: &api.Value_StrVal{
					StrVal: v[:min(rt.cfg.tag_maxlen, len(v))],
				},
			},
		})
	}

	assign, err := rt.dio.NewTxn().Mutate(rt.ctx, mu)
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		back = RetNotAvailable
		return
	}

	back, err = json.Marshal(callback{
		Success: "200",
		Error:   "",
		Data:    assign.Uids["doc"],
	})
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		panic(err)
	}
}
