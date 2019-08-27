package api

import (
	"crypto/sha256"
	"encoding/hex"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"os"
	"testing"
	"time"
)

func TestLogin(t *testing.T) {
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
		"name":     "testuser",
		"username": "testuser",
		"passwd":   hex.EncodeToString(pwhash[:]),
	}

	// register the user
	cb := tpost("http://127.0.0.1:8848/register", values, nil)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	jar, err := cookiejar.New(nil)
	if err != nil {
		t.Fatal(err)
	}

	client := &http.Client{
		Jar: jar,
	}

	// test1: to login, must first get
	cb = tpost("http://127.0.0.1:8848/login", strStrMap{}, client)
	if cb.Error != "need permission" {
		t.Fatalf("%+v\n", cb)
	}

	// test2: login correctly
	cb = tget("http://127.0.0.1:8848/login", values, client)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	var exceptpasswd [sha256.Size]byte
	{
		urlh, err := url.Parse("http://127.0.0.1:8848/login")
		if err != nil {
			t.Fatal(err)
		}
		cookies := client.Jar.Cookies(urlh)

		salt := cb.Data.(strAnyMap)["salt"].(string)

		l1 := len(salt)
		l2 := len(values["passwd"])
		l3 := 0
		l3v := ""

		for _, cookie := range cookies {
			if cookie.Name == "sessionid" {
				l3 = len(cookie.Value)
				l3v = cookie.Value
			}
		}

		passwordbytes := make([]byte, l1+l2+l3)
		copy(passwordbytes, salt)
		copy(passwordbytes[l1:], values["passwd"])
		copy(passwordbytes[l1+l2:], l3v)
		exceptpasswd = sha256.Sum256(passwordbytes)
		values["passwd"] = hex.EncodeToString(exceptpasswd[:])
	}

	cb = tpost("http://127.0.0.1:8848/login", values, client)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	// test3: not allow to login repeatly
	cb = tpost("http://127.0.0.1:8848/login", values, client)
	if cb.Error != "already logined" {
		t.Fatalf("%+v\n", cb)
	}

	// test4: password incorrect?
	jar, err = cookiejar.New(nil)
	if err != nil {
		t.Fatal(err)
	}

	client.Jar = jar

	cb = tget("http://127.0.0.1:8848/login", values, client)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	exceptpasswd[0] = ';'
	values["passwd"] = hex.EncodeToString(exceptpasswd[:])
	cb = tpost("http://127.0.0.1:8848/login", values, client)
	if cb.Error != "password incorrect" {
		t.Fatalf("%+v\n", cb)
	}

	// test5: no such user
	values["name"] = "xvcxbv"
	cb = tpost("http://127.0.0.1:8848/login", values, client)
	if cb.Error != "no such user" {
		t.Fatalf("%+v\n", cb)
	}

	// test6: name restrictions
	// TODO: more invalid test
	values["name"] = "cxbv"
	cb = tpost("http://127.0.0.1:8848/login", values, client)
	if cb.Success != "400" {
		t.Fatalf("%+v\n", cb)
	}
}
