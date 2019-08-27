package main

import (
	"context"
	"flag"
	"log"
	"github.com/dgraph-io/dgo"
	"github.com/dgraph-io/dgo/protos/api"
	"google.golang.org/grpc"
	"encoding/json"
	"fmt"
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

	mu := &api.Mutation{
		CommitNow: true,
	}

	type arrays struct{
		Uids	[]Person `json:"info"`
	}

	var1 := make(map[string]string)
	var1["$enname"] = "TaoYe"
	q1 := `query wanghainfo($enname: string){
		info(func: eq(nameOFen, $enname)){
			uid
		}
	}`

	resp, err := dg.NewTxn().QueryWithVars(ctx,q1,var1)
	if err != nil {
		log.Println(err)
	}

	var r1 arrays
	var r2 arrays

	err = json.Unmarshal(resp.Json, &r1)
	if err != nil{
		log.Println(err)
	}
	Uid_wangha := r1.Uids[0].Uid


	var1["$enname"] = "wanghe"
        q2 := `query wanghainfo($enname: string){
                info(func: eq(nameOFen, $enname)){
                        uid
                }
        }`

	resp, err = dg.NewTxn().QueryWithVars(ctx,q2,var1)
	if err != nil{
		log.Println(err)
	}

	err = json.Unmarshal(resp.Json, &r2)
	if err != nil{
		log.Println(err)
	}
	Uid_TaoYe := r2.Uids[0].Uid

	t := fmt.Sprintf("<%s> <friend> <%s> .",Uid_wangha,Uid_TaoYe)
	mu.SetNquads = []byte(t)

	_,err = dg.NewTxn().Mutate(ctx,mu)
	if err != nil{
		log.Println(err)
	}

}
