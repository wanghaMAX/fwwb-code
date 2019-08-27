package main

import (
	"context"
	"flag"
	"log"
	"github.com/dgraph-io/dgo"
	"github.com/dgraph-io/dgo/protos/api"
	"google.golang.org/grpc"
	"encoding/json"
)

type Person struct{
	Uid		string	`json:"uid,omitempty"`
	Name		string	`json:"name,omitempty"`
	From		string	`json:"from,omitempty"`
	NameOFcn	string	`json:"nameOFcn,omitempty"`
	NameOFjp	string	`json:"nameOFjp,omitempty"`
	NameOFen	string	`json:"nameOFen,omitempty"`
	Age		int	`json:"age,omitempty"`
	Friends		[]Person `json:"friends,omitempty"`
}

var (
	dgraph = flag.String("d", "127.0.0.1:9080", "Dgraph server address")
)

func main() {
	flag.Parse()
	conn, err := grpc.Dial(*dgraph, grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	dg := dgo.NewDgraphClient(api.NewDgraphClient(conn))
	ctx := context.Background()

	vars := make(map[string]string)
	vars["$enname"] = "ZhaoYao"
	q := `query wanghainfo($enname: string){
		info(func: eq(nameOFen, $enname)){
			uid
			expand(_all_)
		}
	}`

	resp, err := dg.NewTxn().QueryWithVars(ctx,q,vars)
	if err != nil {
		log.Println(err)
	}

	type arrays struct{
		Uids	[]Person `json:"info"`
	}

	var r arrays

	err = json.Unmarshal(resp.Json, &r)
	if err != nil{
		log.Println(err)
	}

	log.Println(string(resp.Json))
	log.Println(r.Uids[0].Uid)
}
