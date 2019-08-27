package api

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/go-ego/riot/types"
	"github.com/pkg/errors"
)

func (rt *Router) getContentHandler(w http.ResponseWriter, r *http.Request) {
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
	isLogin := len(back) == 0 && (sess != nil) && sess.online

	pb := strAnyMap{}
	body, _ := ioutil.ReadAll(r.Body)
	err = json.Unmarshal(body, &pb)
	if err != nil {
		back = RetInvalid
		return
	}
	p := strstrmap(pb)

	switch p["category"] {
	case "new":
		resp, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ results(func: has(isdoc), orderdesc: time, first:20, offset: %s) { docid, cover, title, content, like, dislike, tags, time, user: ~push{uid, username, avatar} } }", p["offset"]))
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			back = RetNotAvailable
			return
		}

		pp := strAnyMap{}
		err = json.Unmarshal(resp.Json, &pp)
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}

		back, err = json.Marshal(callback{
			Success: "200",
			Error:   "",
			Data:    pp["results"],
		})
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}
	case "hot":
		resp, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ results(func: has(isdoc), orderdesc: hot, first:20, offset: %s) { docid, cover, title, content, like, dislike, tags, time, user: ~push{uid, username, avatar} } }", p["offset"]))
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			back = RetNotAvailable
			return
		}

		pp := strAnyMap{}
		err = json.Unmarshal(resp.Json, &pp)
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}

		back, err = json.Marshal(callback{
			Success: "200",
			Error:   "",
			Data:    pp["results"],
		})
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}
	case "nearby":
		if len(p["x"]) == 0 || len(p["y"]) == 0 {
			back = RetInvalid
			return
		}

		resp, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ results(func: has(isdoc), orderdesc: time, first:20, offset: %s) @filter(near(location, [%s, %s], 3000)) { docid, cover, title, content, like, dislike, tags, time, user: ~push{uid, username, avatar} } }", p["offset"], p["x"], p["y"]))
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			back = RetNotAvailable
			return
		}

		pp := strAnyMap{}
		err = json.Unmarshal(resp.Json, &pp)
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}

		back, err = json.Marshal(callback{
			Success: "200",
			Error:   "",
			Data:    pp["results"],
		})
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}
	case "subscribe":
		if !isLogin {
			back = RetNeedPerm
			return
		}

		resp, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ results(func: has(isdoc), orderdesc: time, first:20, offset: %s) @cascade { docid, cover, title, content, like, dislike, tags, time, user: ~push{uid, username, avatar, ~follow @filter(uid(%s)) } } }", p["offset"], sess.uid))
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			back = RetNotAvailable
			return
		}

		pp := strAnyMap{}
		err = json.Unmarshal(resp.Json, &pp)
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}

		back, err = json.Marshal(callback{
			Success: "200",
			Error:   "",
			Data:    pp["results"],
		})
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}
	case "mime":
		if !isLogin {
			back = RetNeedPerm
			return
		}

		resp, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ results(func: uid(%s)) { push(orderdesc: time, first: 20, offset: %s) { docid, cover, title, content, like, dislike, tags, time, user: ~push{uid, username, avatar } } } }", sess.uid, p["offset"]))
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			back = RetNotAvailable
			return
		}

		pp := strAnyMap{}
		err = json.Unmarshal(resp.Json, &pp)
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}
		res := pp["results"].([]interface{})
		if len(res) == 0 {
			back = RetSuccess
			return
		}

		back, err = json.Marshal(callback{
			Success: "200",
			Error:   "",
			Data:    res[0].(strAnyMap)["push"],
		})
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}
	case "ad":
		resp, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ results(func: has(isdoc), orderdesc: time, first:20, offset: %s) @filter(has(isad)) { docid, cover, title, content, like, dislike, tags, time, user: ~push{uid, username, avatar} } }", p["offset"]))
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			back = RetNotAvailable
			return
		}

		pp := strAnyMap{}
		err = json.Unmarshal(resp.Json, &pp)
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}

		back, err = json.Marshal(callback{
			Success: "200",
			Error:   "",
			Data:    pp["results"],
		})
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}
	case "search":
		search := rt.search.Search(types.SearchReq{Text: p["search"]})
		docs := search.Docs.(types.ScoredDocs)

		ret := []interface{}{}

		for _, v := range docs[:min(len(docs), 20)] {
			resp, err := rt.dio.NewReadOnlyTxn().Query(rt.ctx, fmt.Sprintf("{ results(func: uid(%s)) { docid, cover, title, content, like, dislike, tags, time, user: ~push{uid, username, avatar} } }", v.DocId))
			if err != nil {
				rt.infof("%+v\n", errors.WithStack(err))
				back = RetNotAvailable
				return
			}

			pp := strAnyMap{}
			err = json.Unmarshal(resp.Json, &pp)
			if err != nil {
				rt.infof("%+v\n", errors.WithStack(err))
				panic(err)
			}

			l := pp["result"].([]interface{})
			if len(l) != 0 {
				ret = append(ret, l[0])
			}
		}

		back, err = json.Marshal(callback{
			Success: "200",
			Error:   "",
			Data:    ret,
		})
		if err != nil {
			rt.infof("%+v\n", errors.WithStack(err))
			panic(err)
		}
	default:
		back = RetInvalidCate
	}
}
