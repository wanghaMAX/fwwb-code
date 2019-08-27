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
	"time"
)

type loc struct {
	Type   string    `json:"type,omitempty"`
	Coords []float64 `json:"coordinates,omitempty"`
}

type note struct {
        Uid             string  `json:"uid,omitempty"`
        Username        string  `json:"username,omitempty"`
	Avatar		string	`json:"avatar,omitempty"`
        Cover           string  `json:"cover,omitempty"`
        Title           string  `json:"title,omitempty"`
        Content         string  `json:"content,omitempty"`
        Like            int     `json:"like,omitempty"`
        Dislike         int     `json:"dislike,omitempty"`
	Tag		[]string `json:"tag,omitempty"`
        Time            time.Time `json:"time,omitempty"`
	Location	loc	`json:"location,omitempty"`
        Url             string  `json:"url,omitempty"`
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

	p1 := note{
		Username: "wangha",
		Avatar: "12332132131",
		Cover: "a good book",
		Title: "a good book",
		Content: "i have a good book",
		Like: 11,
		Dislike: 2,
		Tag: []string{"book","good",""},
		Time: time.Now(),
		Location: loc{
			Type:	"Point",
			Coords:	[]float64{1.32,33.4442},
		},
		Url: "",
	}

	p2 := note{
                Username: "wangha",
                Avatar: "12332132131",
                Cover: "a good dog",
                Title: "dogs are good",
                Content: "i buuy a good dog",
                Like: 21,
                Dislike: 0,
                Tag: []string{"dog","good",""},
                Time: time.Now(),
		Location: loc {
			Type:	"Point",
			Coords:	[]float64{12.423,7.432},
		},
                Url: "",
        }

	p3 := note{
                Username: "ChaoChen",
                Avatar: "234534543",
                Cover: "happy new years",
                Title: "happ new years",
                Content: "thacks for watching",
                Like: 2,
                Dislike: 5,
                Tag: []string{"new","year","happy"},
                Time: time.Now(),
		Location: loc{
			Type:	"Point",
			Coords:	[]float64{12.425,7.421},
		},
                Url: "",
        }

	p4 := note{
                Username: "wanghe",
                Avatar: "34288",
                Cover: "a bad book",
                Title: "a bad book",
                Content: "i have a bad book",
                Like: 14,
                Dislike: 67,
                Tag: []string{"book","bad"},
                Time: time.Now(),
		Location: loc{
			Type:	"Point",
			Coords:	[]float64{4.543,123.444},
		},
                Url: "",
        }

	p5 := note{
                Username: "TaoYe",
                Avatar: "488778",
                Cover: "i am a happy pig",
                Title: "i am a happy pig",
                Content: "now, i decide to be a pig but happy",
                Like: 666,
                Dislike: 0,
                Tag: []string{"pig","happy"},
                Time: time.Now(),
		Location: loc{
			Type:	"Point",
			Coords:	[]float64{96.4500,74.8801},
		},
                Url: "",
        }

	op := &api.Operation{}
	op.Schema = `
		username: string @index(term).
		avatar: string .
		cover: string .
		title: string .
		content: string .
		like: int .
		dislike: int .
		time: datetime @index(day) .
		tag: [string] @index(term) .
		location: geo @index(geo) .
		url: string .
	`

	ctx := context.Background()
	if err := dg.Alter(ctx, op); err != nil {
		log.Fatal(err)
	}

	var p = [5]note{p1,p2,p3,p4,p5}
	var uidStorage [5]string
	var a int = 0

	for k,x := range p {
		log.Println(k)
		pb, err := json.Marshal(x)
		if err != nil {
			log.Println(err)
		}
		assigned, err := dg.NewTxn().Mutate(ctx, &api.Mutation{SetJson: pb, CommitNow: true})
		if err != nil {
			log.Println(err)
		}
		log.Println(assigned)
		tempStr := assigned.Uids["blank-0"]
		uidStorage[a] = tempStr
		a = a + 1
	}

	type cd struct {
		Uid	string	`json:"uid"`
	}

	type ab struct {
		Me	[]cd	`json:"me"`
	}

	for k,x := range uidStorage {
		variables := map[string]string{"$username": p[k].Username}
		q := `query Me($username: string){
		me(func: eq(nameOFen,$username)) {
			uid
		}
		}`
		resp, err := dg.NewTxn().QueryWithVars(ctx, q, variables)
		if err != nil {
			log.Fatal(err)
			panic(err)
		}

		var r ab
		err = json.Unmarshal(resp.Json,&r)
		if err != nil{
			panic(err)
		}

		log.Println(r.Me[0].Uid,"|",x,"|",k)
		t := fmt.Sprintf("<%s> <push> <%s> .",r.Me[0].Uid,x)
		_,err = dg.NewTxn().Mutate(ctx,&api.Mutation{SetNquads: []byte(t), CommitNow: true})
		if err != nil {
			panic(err)
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
