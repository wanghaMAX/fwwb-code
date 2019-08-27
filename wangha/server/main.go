package main

import (
	"net/http"

	api "./api"
	_ "github.com/mattn/go-sqlite3"
)

func main() {
	rt, err := api.New(api.WithSearchPath("/home/wangha/work/go/fwwb-code/wangha/server/search"),
		api.WithImagePath("/home/wangha/work/go/fwwb-code/wangha/server/images"),
		api.WithVisionProxy("127.0.0.1:1080"))
	if err != nil {
		panic(err)
	}
	defer rt.Close()

	rt.LoadSchema()

	srv := &http.Server{
		Addr:    ":8085",
		Handler: rt,
	}

	srv.ListenAndServe()
	defer srv.Close()
}
