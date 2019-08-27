package api

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"

	"github.com/dgraph-io/dgo/protos/api"
)

func (rt *Router) updateinfoHandler(w http.ResponseWriter, r *http.Request) {
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
		return
	}
	p := strstrmap(pb)

	back = checkEscape(
		p["avatar"],
		p["username"],
		p["email"],
		p["phone"],
		p["passwd"],
		p["sex"],
		p["birthday"],
		p["city"],
		p["stats"],
	)
	if len(back) != 0 {
		return
	}

	resjson, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ exist(func: has(isuser)) @filter(eq(email, \"%s\") OR eq(phone, \"%s\") OR eq(username, \"%s\")) { uid } }", p["name"], p["name"], p["name"]))
	if err != nil {
		rt.infof("%s\n", err)
		back = RetNotAvailable
		return
	}

	res := struct {
		Exist []struct {
			Uid string `json:"uid"`
		} `json:"exist"`
	}{}

	err = json.Unmarshal(resjson.Json, &res)
	if err != nil {
		panic(err)
	}

	mu := &api.Mutation{CommitNow: true}

	for k, v := range p {
		switch k {
		case "privacy":
			privacy := userinfo_usertype(0)

			privacies := strings.Split(v, "_")
			for kk, vv := range privacies {
				if len(vv) != 1 {
					continue
				}

				privacy += int64(((vv[0] - '0') & 3)) << (uint(kk) * 2)
			}

			mu.Set = append(mu.Set, &api.NQuad{
				Subject:   sess.uid,
				Predicate: "privacy",
				ObjectValue: &api.Value{
					Val: &api.Value_IntVal{
						IntVal: privacy,
					},
				},
			})
		case "passwd":
			if len(v) != PASSWORD_LEN {
				back = RetInvalid
				return
			}

			mu.Set = append(mu.Set, &api.NQuad{
				Subject:   sess.uid,
				Predicate: "passwd",
				ObjectValue: &api.Value{
					Val: &api.Value_StrVal{
						StrVal: v,
					},
				},
			})
		case "avatar":
			if len(v) != AVATAR_LEN {
				back = RetInvalid
				return
			}

			mu.Set = append(mu.Set, &api.NQuad{
				Subject:   sess.uid,
				Predicate: "avatar",
				ObjectValue: &api.Value{
					Val: &api.Value_StrVal{
						StrVal: v,
					},
				},
			})
		case "sex":
			if len(v) != 1 {
				back = RetInvalid
				return
			}

			mu.Set = append(mu.Set, &api.NQuad{
				Subject:   sess.uid,
				Predicate: "sex",
				ObjectValue: &api.Value{
					Val: &api.Value_StrVal{
						StrVal: v,
					},
				},
			})
		default:
			mu.Set = append(mu.Set, &api.NQuad{
				Subject:   sess.uid,
				Predicate: k,
				ObjectValue: &api.Value{
					Val: &api.Value_StrVal{
						StrVal: v,
					},
				},
			})
		}
	}

	_, err = rt.dio.NewTxn().Mutate(rt.ctx, mu)
	if err != nil {
		rt.infof("%s\n", err)
		back = RetNotAvailable
		return
	}

	back = RetSuccess
}
