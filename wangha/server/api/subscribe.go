package api

import (
	"encoding/json"
	"io/ioutil"
	"net/http"

	"github.com/dgraph-io/dgo/protos/api"
)

func (rt *Router) subscribeHandler(w http.ResponseWriter, r *http.Request) {
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

	p := []string{}
	body, _ := ioutil.ReadAll(r.Body)
	err = json.Unmarshal(body, &p)
	if err != nil {
		rt.infof("%s\n", back)
		back = RetInvalid
		return
	}

	mu := &api.Mutation{CommitNow: true}

	for _, v := range p {
		mu.Set = append(mu.Set, &api.NQuad{
			Subject:   sess.uid,
			Predicate: "tags",
			ObjectValue: &api.Value{
				Val: &api.Value_StrVal{
					StrVal: v,
				},
			},
		})
	}

	_, err = rt.dio.NewTxn().Mutate(rt.ctx, mu)
	if err != nil {
		rt.infof("%s\n", err)
		back = RetNotAvailable
		return
	}

	back = RetSuccess
}
