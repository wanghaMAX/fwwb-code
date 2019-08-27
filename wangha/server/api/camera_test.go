package api

import (
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"io/ioutil"
	"net/http"
	"net/http/cookiejar"
	"os"
	"testing"
	"time"
)

func TestCamera(t *testing.T) {
	rt, err := New(WithVisionProxy("127.0.0.1:1080"))
	if err != nil {
		panic(err)
	}
	rt.RemoveUser("testuser")
	defer rt.Close()
	defer os.RemoveAll("./images")

	err = rt.LoadSchema()
	if err != nil {
		t.Fatal(err)
	}

	srv := &http.Server{
		Addr:    ":8848",
		Handler: rt,
	}
	defer srv.Close()

	go func() {
		srv.ListenAndServe()
	}()

	time.Sleep(500 * time.Microsecond)

	pwhash := sha256.Sum256(str_bytes("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"))

	f, err := os.Open("./baidu.png")
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()

	pbytes, err := ioutil.ReadAll(f)
	if err != nil {
		t.Fatal(err)
	}

	imghash := sha256.Sum256(pbytes)

	values := strStrMap{
		"username": "testuser",
		"passwd":   hex.EncodeToString(pwhash[:]),
		"mode":     "web",
		"maxres":   "10",
		"image":    base64.StdEncoding.EncodeToString(pbytes),
	}

	jar, err := cookiejar.New(nil)
	if err != nil {
		t.Fatal(err)
	}

	client := &http.Client{
		Jar: jar,
	}

	// test1: need perm
	cb := tpost("http://127.0.0.1:8848/camera", values, client)
	if cb.Error != "need permission" {
		t.Fatalf("%+v\n", cb)
	}

	// test2: update image correctly
	cb = tpost("http://127.0.0.1:8848/register", values, client)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	cb = tpost("http://127.0.0.1:8848/image", values, client)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	values["image"] = hex.EncodeToString(imghash[:])
	cb = tpost("http://127.0.0.1:8848/camera", values, client)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	// test3: invalid
	values["mode"] = ""
	cb = tpost("http://127.0.0.1:8848/camera", values, client)
	if cb.Error != "invalid parameters" {
		t.Fatalf("%+v\n", cb)
	}
}
