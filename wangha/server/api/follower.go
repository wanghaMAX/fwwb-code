package api

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

func (rt *Router) followerHandler(w http.ResponseWriter, r *http.Request) {
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

	p := strAnyMap{}
	body, _ := ioutil.ReadAll(r.Body)
	err = json.Unmarshal(body, &p)
	if err != nil {
		rt.infof("%s\n", err)
		back = RetInvalid
		return
	}

	mode, ok := p["mode"].(string)
	if !ok {
		back = RetInvalid
		return
	}

	_offset, ok := p["offset"].(float64)
	if !ok {
		back = RetInvalid
		return
	}
	offset := int64(_offset)

	var data interface{}
	switch mode {
	case "follower":
		res, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ uid(func: uid(%s)) { follow(orderasc: username, offset: %d, first: 20) { uid } } }", sess.uid, offset))
		if err != nil {
			rt.infof("%s\n", err)
			back = RetNotAvailable
			return
		}

		p := strAnyMap{}
		err = json.Unmarshal(res.Json, &p)
		if err != nil {
			panic(err)
		}
		data = p["uid"]
	case "~follower":
		//res, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ uid(func: has(userid), orderasc: uid, offset: %d, first: 20) @cascade { uid, follow @filter(eq(uid, \"%s\")) {} } }", offset, sess.uid))
		res, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ uid(func: uid(%s)) { follow : ~follow(orderasc: username, offset: %d, first: 20) { uid } } }", sess.uid, offset))
		if err != nil {
			rt.infof("%s\n", err)
			back = RetNotAvailable
			return
		}

		p := strAnyMap{}
		err = json.Unmarshal(res.Json, &p)
		if err != nil {
			panic(err)
		}
		data = p["uid"]
	default:
		back = RetInvalid
	}

	back, err = json.Marshal(callback{
		Success: "200",
		Error:   "",
		Data:    data,
	})
	if err != nil {
		panic(err)
	}

	return
}
