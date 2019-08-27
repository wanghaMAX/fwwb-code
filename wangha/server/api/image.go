package api

import (
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
)

type image struct {
	Format string `json:"format"`
	Image  string `json:"image"`
}

func (rt *Router) imageHandler(w http.ResponseWriter, r *http.Request) {
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
		back = RetInvalid
		rt.infof("%s\n", back)
		return
	}
	p := strstrmap(pb)

	data, err := base64.StdEncoding.DecodeString(p["image"])
	if err != nil {
		r := callback{
			Success: "400",
			Error:   fmt.Sprintf("invalid base64 for %v", err),
			Data:    nil,
		}

		back, err = json.Marshal(r)
		if err != nil {
			panic(err)
		}

		rt.infof("%s\n", back)
		return
	}

	hash := sha256.Sum256(data)
	hashhex := hex.EncodeToString(hash[:])

	dir := filepath.Join(rt.cfg.image_path, string(hashhex[0]), string(hashhex[1]))
	err = os.MkdirAll(dir, 0755)
	if err != nil {
		panic(err)
	}

	f, err := os.OpenFile(filepath.Join(dir, fmt.Sprintf("%s.%s", hashhex, p["format"])), os.O_RDWR|os.O_CREATE, 0644)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	_, err = f.Write(data)
	if err != nil {
		panic(err)
	}

	back = RetSuccess
}
