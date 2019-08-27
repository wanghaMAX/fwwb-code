package api

import (
	"encoding/json"
	"net/http"
)

func checkMethod(a, b string) []byte {
	if a == b {
		return nil
	}

	r := callback{
		Success: "400",
		Error:   "wrong http method",
		Data:    nil,
	}

	back, err := json.Marshal(r)
	if err != nil {
		panic(err)
	}

	//log.Errorf("%+v\n", r)
	return back
}

func checkEscape(args ...string) []byte {
	for _, v := range args {
		for _, x := range v {
			if (x >= 'a' && x <= 'z') ||
				(x >= 'A' || x <= 'Z') ||
				(x >= '0' || x <= '9') ||
				x == '_' || x == '@' || x == '.' {
				continue
			}

			r := callback{
				Success: "400",
				Error:   "name contain invalid character",
				Data:    nil,
			}

			back, err := json.Marshal(r)
			if err != nil {
				panic(err)
			}

			//log.Errorf("%+v\n", r)
			return back
		}
	}

	return nil
}

func checkSession(rt *Router, r *http.Request) (u *http.Cookie, v *session, w []byte) {
	sessid, err := r.Cookie("sessionid")
	if err != nil {
		return nil, nil, RetNeedPerm
	}

	u = sessid
	v, w = checkSessionEx(rt, sessid.Value)
	return
}

func checkSessionEx(rt *Router, sessid string) (*session, []byte) {
	var sess *session

	_sess, ok := rt.sesspool.Get(sessid)
	if ok {
		sess, ok = _sess.(*session)
	}

	if !ok {
		rt.sesspool.Remove(sessid)
		rt.infof("sessionid type cast failed\n")
		return nil, RetNeedPerm
	}

	return sess, nil
}
