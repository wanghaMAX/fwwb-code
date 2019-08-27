package api

import (
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"net/http"
	"net/http/cookiejar"
	"os"
	"testing"
	"time"
)

func TestImage(t *testing.T) {
	rt, err := New()
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

	values := strStrMap{
		"username": "testuser",
		"passwd":   hex.EncodeToString(pwhash[:]),
		"format":   "jpg",
		"image":    base64.StdEncoding.EncodeToString([]byte("xxxx")),
	}

	jar, err := cookiejar.New(nil)
	if err != nil {
		t.Fatal(err)
	}

	client := &http.Client{
		Jar: jar,
	}

	// test1: need perm
	cb := tpost("http://127.0.0.1:8848/image", values, client)
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

	// test3: invalid base64 chracter
	values["image"] = values["image"][:len(values["image"])-1]
	cb = tpost("http://127.0.0.1:8848/image", values, client)
	if cb.Success != "400" {
		t.Fatalf("%+v\n", cb)
	}
}
