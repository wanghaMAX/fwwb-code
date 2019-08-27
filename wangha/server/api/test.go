package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

// internal test wrappers
func tget(s string, m interface{}, client *http.Client) *callback {
	var resp *http.Response
	var err error

	if client == nil {
		resp, err = http.Get(s)
	} else {
		resp, err = client.Get(s)
	}

	if err != nil {
		panic(err)
	}

	buf, _ := ioutil.ReadAll(resp.Body)
	resp.Body.Close()

	cb := &callback{}
	err = json.Unmarshal(buf, cb)
	if err != nil {
		fmt.Printf("%s\n", string(buf))
		panic(err)
	}

	return cb
}

func tpost(s string, m interface{}, client *http.Client) *callback {
	jsonValue, _ := json.Marshal(m)

	var resp *http.Response
	var err error

	if client == nil {
		resp, err = http.Post(s, "application/json", bytes.NewReader(jsonValue))
	} else {
		resp, err = client.Post(s, "application/json", bytes.NewReader(jsonValue))
	}

	if err != nil {
		panic(err)
	}

	cb := &callback{}

	buf, _ := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	err = json.Unmarshal(buf, cb)
	if err != nil {
		fmt.Printf("%s\n", string(buf))
		panic(err)
	}

	return cb
}
