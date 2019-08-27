package api

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/dgraph-io/dgo/protos/api"
	"github.com/pkg/errors"
)

func (rt *Router) registerHandler(w http.ResponseWriter, r *http.Request) {
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

	pb := strAnyMap{}
	body, _ := ioutil.ReadAll(r.Body)
	err = json.Unmarshal(body, &pb)
	if err != nil {
		rt.infof("%s\n", err)
		back = RetInvalid
		return
	}
	p := strstrmap(pb)

	l1 := len(p["email"])
	l2 := len(p["phone"])
	l3 := len(p["username"])
	l4 := len(p["passwd"])

	if len(p["sex"]) > 1 {
		back = RetInvalid
		return
	}

	if l3 < rt.cfg.username_minlen || l4 != PASSWORD_LEN {
		r := callback{
			Success: "400",
			Error:   fmt.Sprintf("(e)name/phone[%d] too short or passwd[%d] not suitable", l3, l4),
			Data:    nil,
		}

		back, err = json.Marshal(r)
		if err != nil {
			panic(err)
		}

		rt.infof("%s\n", back)
		return
	}

	if l3 < rt.cfg.username_minlen || !rt.cfg.username_pattern.MatchString(p["username"]) {
		back = RetInvalidUsername
		rt.infof("%s\n", back)
		return
	}

	{
		if l1 == 0 {
			p["email"] = ";"
		}

		if l2 == 0 {
			p["phone"] = ";"
		}

		resjson, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ exist(func: has(isuser)) @filter(eq(email, \"%s\") OR eq(phone, \"%s\") OR eq(username, \"%s\")) @cascade { uid } }", p["email"], p["phone"], p["username"]))
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			back = RetNotAvailable
			return
		}

		res := struct {
			Exist []struct {
				Uid string `json:"uid"`
			} `json:"exist"`
		}{}

		if resjson != nil {
			json.Unmarshal(resjson.Json, &res)
		}

		if len(res.Exist) != 0 {
			back = RetUserExisted
			rt.infof("%s\n", back)
			return
		}

		if l1 == 0 {
			p["email"] = ""
		}

		if l2 == 0 {
			p["phone"] = ""
		}
	}

	mu := &api.Mutation{CommitNow: true}

	mu.Set = append(mu.Set, &api.NQuad{
		Subject:   "_:user",
		Predicate: "isuser",
		ObjectValue: &api.Value{
			Val: &api.Value_BoolVal{
				BoolVal: true,
			},
		},
	})

	for k, v := range p {
		switch k {
		case "avatar", "username", "email", "phone", "passwd", "sex", "birthday", "city", "stats":
			back = checkEscape(v)
			if len(back) != 0 {
				return
			}
		default:
			continue
		}

		mu.Set = append(mu.Set, &api.NQuad{
			Subject:   "_:user",
			Predicate: k,
			ObjectValue: &api.Value{
				Val: &api.Value_StrVal{
					StrVal: v,
				},
			},
		})
	}

	mu.Set = append(mu.Set, &api.NQuad{
		Subject:   "_:user",
		Predicate: "privacy",
		ObjectValue: &api.Value{
			Val: &api.Value_IntVal{
				IntVal: rt.cfg.default_privacy,
			},
		},
	})

	sessid := rt.NewSessid()

	mu.Set = append(mu.Set, &api.NQuad{
		Subject:   "_:user",
		Predicate: "sessid",
		ObjectValue: &api.Value{
			Val: &api.Value_StrVal{
				StrVal: sessid,
			},
		},
	})

	res, err := rt.dio.NewTxn().Mutate(rt.ctx, mu)
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		back = RetNotAvailable
		return
	}

	http.SetCookie(w, &http.Cookie{
		Name:   "sessionid",
		Value:  string(sessid),
		MaxAge: rt.cfg.login_defage,
	})

	sess := &session{
		online: true,
		uid:    res.Uids["user"],
	}

	rt.sesspool.Set(sessid, sess)

	back = RetSuccess
}
