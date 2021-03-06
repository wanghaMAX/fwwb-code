package api

import (
	"crypto/sha256"
	"encoding/hex"
	"net/http"
	"net/http/cookiejar"
	"os"
	"testing"
	"time"
)

func TestUserinfo(t *testing.T) {
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
	}

	jar, err := cookiejar.New(nil)
	if err != nil {
		t.Fatal(err)
	}

	client := &http.Client{
		Jar: jar,
	}

	// test1: invalid session
	cb := tpost("http://127.0.0.1:8848/userinfo", values, client)
	if cb.Error != "no such user" {
		t.Fatalf("%+v\n", cb)
	}

	// test2: get info correctly
	cb = tpost("http://127.0.0.1:8848/register", values, client)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	cb = tpost("http://127.0.0.1:8848/userinfo", values, client)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	// test3: get self
	values["username"] = ""
	cb = tpost("http://127.0.0.1:8848/userinfo", values, client)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	// test4: get self without perm
	jar, err = cookiejar.New(nil)
	if err != nil {
		t.Fatal(err)
	}

	client.Jar = jar

	cb = tget("http://127.0.0.1:8848/login", values, client)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	values["username"] = ""
	cb = tpost("http://127.0.0.1:8848/userinfo", values, client)
	if cb.Error != "no such user" {
		t.Fatalf("%+v\n", cb)
	}
}
