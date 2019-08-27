package api

import (
	"crypto/sha256"
	"encoding/hex"
	"net/http"
	"os"
	"testing"
	"time"
)

func TestRegister(t *testing.T) {
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
		"email":    "testuser",
		"phone":    "testuser",
		"username": "testuser",
		"passwd":   hex.EncodeToString(pwhash[:]),
	}

	// test1: register correctly
	cb := tpost("http://127.0.0.1:8848/register", values, nil)
	if cb.Success != "200" {
		t.Fatalf("%+v\n", cb)
	}

	// test2: repeat name
	cb = tpost("http://127.0.0.1:8848/register", values, nil)
	if cb.Error != "email, phone, or username existed" {
		t.Fatalf("%+v\n", cb)
	}

	// test3: name is too short
	values["username"] = "xgh"
	cb = tpost("http://127.0.0.1:8848/register", values, nil)
	if cb.Success != "400" {
		t.Fatalf("%+v\n", cb)
	}

	// test4: invalid name
	// TODO: more invalid test
	values["username"] = "xgheh;2"
	cb = tpost("http://127.0.0.1:8848/register", values, nil)
	if cb.Error != "name should match the pattern, and not too short" {
		t.Fatalf("%+v\n", cb)
	}
}
