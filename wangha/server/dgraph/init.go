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

	p1 := Person{
		Name: "wangha",
		Age: 17,
		From: "China",
		NameOFen: "wangha",
		NameOFcn: "王哈",
		NameOFjp: "王ハ",
	}
	p2 := Person{
		Name: "chenchao",
		Age: 22,
		From: "China",
		NameOFen: "ChaoChen",
		NameOFcn: "陈超",
	}
	p3 := Person{
		Name: "xhe",
		Age: 18,
		From: "Japan",
		NameOFen: "wanghe",
		NameOFcn: "x鹤",
	}
	p4 := Person{
		Name: "changyang",
		Age: 19,
		From: "England",
		NameOFcn: "常飏",
	}
	p5 := Person{
		Name: "yetao",
		Age: 18,
		From: "Russian",
		NameOFen: "TaoYe",
		NameOFcn: "叶掏",
	}

	op := &api.Operation{}
	op.Schema = `
		name: string .
		age: int .
		from: string .
		nameOFcn: string @index(term) .
		nameOFjp: string @index(term) .
		nameOFen: string @index(term) .
	`

	ctx := context.Background()
	if err := dg.Alter(ctx, op); err != nil {
		log.Fatal(err)
	}

	mu := &api.Mutation{
		CommitNow: true,
	}

	var p = [5]Person{p1,p2,p3,p4,p5}

	for _,x := range p {
		pb, err := json.Marshal(x)
		if err != nil {
			log.Println(err)
		}
		mu.SetJson = pb
		_,err = dg.NewTxn().Mutate(ctx, mu)
		if err != nil {
			log.Println(err)
		}
	}
}

/*
resp, err := dg.NewTxn().Mutate(context.Background(), `{
set {
_:wangha <name> "wangha" .
_:chenyichao <name> "chenyichao" .
_:wanghe <name> "wanghe" .

_:detail1 <username> _:wangha .
_:detail1 <usernameOFjp> "王ハ" .
_:detail1 <usernameOFcn> "王哈" .
_:detail1 <friend> _:chenyichao . 
_:detail1 <age> "22" .

_:detail2 <username> _:chenyichao .
_:detail2 <usernameOFjp> "chenyichao" . 
_:detail2 <usernameOFcn> "陈逸超" .
_:detail2 <age> "21" . 

_:detail3 <username> _:wanghe . 
_:detail3 <usernameOFjp> "王He" . 
_:deatil3 <usernameOFen> "wanghe" . 
_:detail3 <age> "20" .
}
}`)
*/
