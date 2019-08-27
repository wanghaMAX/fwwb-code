package api

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/dgraph-io/dgo/protos/api"
	"github.com/pkg/errors"
)

type userinfo struct {
	Uid      string            `json:"uid"`
	Avatar   string            `json:"avatar"`
	Username string            `json:"username"`
	Sex      string            `json:"sex"`
	Email    string            `json:"email"`
	Phone    string            `json:"phone"`
	Birthday string            `json:"birthday"`
	City     string            `json:"city"`
	Stats    string            `json:"stats"`
	Privacy  userinfo_usertype `json:"privacy"`
}

func privacy_safe(r string, t, e userinfo_usertype, offset uint) string {
	h := (e & (3 << offset)) >> offset
	if t >= h {
		return r
	} else {
		return ""
	}
}

func (rt *Router) userinfoHandler(w http.ResponseWriter, r *http.Request) {
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
	_, sess, _ = checkSession(rt, r)

	pb := strAnyMap{}
	body, _ := ioutil.ReadAll(r.Body)
	err = json.Unmarshal(body, &pb)
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		back = RetInvalid
		return
	}
	p := strstrmap(pb)

	usertype := USERINFO_OTHERS

	var resjson *api.Response

	if sess != nil && len(sess.uid) != 0 {
		resjson, err = rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ exist(func: has(isuser)) @filter(uid(<%s>)) { uid, avatar, username, sex, email, phone, birthday, city, stats, privacy, follow: ~follow @filter(eq(username, \"%s\")) { uid, avatar, username, sex, email, phone, birthday, city, stats, privacy } } }", sess.uid, p["username"]))
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			back = RetNotAvailable
			return
		}
	} else {
		back = RetNoSuchUser
		rt.infof("%+v, %s\n", sess, back)
		return
	}

	res := struct {
		Exist []struct {
			userinfo
			Follow []userinfo `json:"follow"`
		}
	}{}

	err = json.Unmarshal(resjson.Json, &res)
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		panic(err)
	}

	var info userinfo

	if len(res.Exist) != 0 {
		if len(res.Exist[0].Follow) != 0 {
			info = res.Exist[0].Follow[0]
			usertype = USERINFO_FRIEND
		} else {
			info = res.Exist[0].userinfo
		}
	} else {
		back = RetNoSuchUser
		rt.infof("%s\n", back)
		return
	}

	privacy := info.Privacy

	back, err = json.Marshal(callback{
		Success: "200",
		Error:   "",
		Data: strStrMap{
			"uid":      privacy_safe(info.Uid, usertype, privacy, USERINFO_AVATAR),
			"avatar":   privacy_safe(info.Avatar, usertype, privacy, USERINFO_AVATAR),
			"username": privacy_safe(info.Username, usertype, privacy, USERINFO_USERNAME),
			"sex":      privacy_safe(info.Sex, usertype, privacy, USERINFO_SEX),
			"email":    privacy_safe(info.Email, usertype, privacy, USERINFO_EMAIL),
			"phone":    privacy_safe(info.Phone, usertype, privacy, USERINFO_PHONE),
			"birthday": privacy_safe(info.Birthday, usertype, privacy, USERINFO_BIRTHDAY),
			"city":     privacy_safe(info.City, usertype, privacy, USERINFO_CITY),
			"stats":    privacy_safe(info.Stats, usertype, privacy, USERINFO_STATS),
		},
	})
	if err != nil {
		rt.infof("%+v\n", errors.WithStack(err))
		panic(err)
	}
}
