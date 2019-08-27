package api

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/dgraph-io/dgo/protos/api"
	"github.com/pkg/errors"
)

func (rt *Router) likeHandler(w http.ResponseWriter, r *http.Request) {
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

	pb := strAnyMap{}
	body, _ := ioutil.ReadAll(r.Body)
	err = json.Unmarshal(body, &pb)
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		back = RetInvalid
		return
	}
	p := strstrmap(pb)

	resp, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ results(func: uid(%s)) { like, dislike } }", p["docid"]))
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		back = RetNotAvailable
		return
	}

	res := struct {
		Results []struct {
			Like    int64 `json:"like"`
			Dislike int64 `json:"dislike"`
		} `json:"results"`
	}{}
	err = json.Unmarshal(resp.Json, &res)
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		panic(err)
	}

	if len(res.Results) == 0 {
		rt.infof("wrong docid\n")
		back = RetInvalid
		return
	}

	if p["like"] == "0" {
		res.Results[0].Dislike += 1
	} else {
		res.Results[0].Like += 1
	}

	_, err = rt.dio.NewTxn().Mutate(rt.ctx, &api.Mutation{
		Set: []*api.NQuad{
			&api.NQuad{
				Subject:   p["docid"],
				Predicate: "like",
				ObjectValue: &api.Value{
					Val: &api.Value_IntVal{
						IntVal: res.Results[0].Like,
					},
				},
			},
			&api.NQuad{
				Subject:   p["docid"],
				Predicate: "dislike",
				ObjectValue: &api.Value{
					Val: &api.Value_IntVal{
						IntVal: res.Results[0].Dislike,
					},
				},
			},
			&api.NQuad{
				Subject:   p["docid"],
				Predicate: "hot",
				ObjectValue: &api.Value{
					Val: &api.Value_IntVal{
						IntVal: res.Results[0].Like - res.Results[0].Dislike,
					},
				},
			},
		},
		CommitNow: true})
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		panic(err)
	}

	back = RetSuccess
}
