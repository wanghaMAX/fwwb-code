package main

import(
	"flag"
	"time"
	"log"
	"context"
	"encoding/json"
	"github.com/dgraph-io/dgo"
    "github.com/dgraph-io/dgo/protos/api"
	"google.golang.org/grpc"
)

type loc struct {
	Type   string    `json:"type,omitempty"`
	Coords []float64 `json:"coordinates,omitempty"`
}

type note struct {
	Uid			string	`json:"uid,omitempty"`
	Id			int64	`json:"id,omitempty"`
	Username	string	`json:"username,omitempty"`
	Cover		string	`json:"cover,omitempty"`
	Title		string	`json:"title,omitempty"`
	Content		string	`json:"content,omitempty"`
	Like		int		`json:"like,omitempty"`
	Dislike		int		`json:"dislike,omitempty"`
	Tag			[]string `json:"tags,omitempty"`
	Time		time.Time `json:"time,omitempty"`
	Location	loc `json:"location,omitempty"`
	Url			string	`json:"url,omitempty"`
}

type strStrMap map[string]string

var (
        dgraph = flag.String("d", "127.0.0.1:9080", "Dgraph server address")
)

func main(){
	conn,err := grpc.Dial(*dgraph, grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
    }
	defer conn.Close()

	// new query client
	dg := dgo.NewDgraphClient(api.NewDgraphClient(conn))
	ctx := context.Background()

	var p strStrMap= make(strStrMap)

	//adjust
	p["category"] = "nearby"
	p["index"] = "1"
	p["locationx"] = "12.420"
	p["locationy"] = "7.42"

	t := time.Now()
	yday := t.AddDate(0,0,-1)
	times := yday.Format("2006-01-02")
	if err != nil {
		log.Println(err)
	}

	var queryStr strStrMap = make(strStrMap)

	queryStr["$time"] = times
	queryStr["$index"] = p["index"]

	q := `query headline($time:string, $index:int){
		hot(func:ge(time,$time), orderdesc:like, first:20, offset:$index)@filter(has(title)){
			uid
			expand(_all_)
		}
	}`
	resp, err := dg.NewTxn().QueryWithVars(ctx,q,queryStr)
	if err != nil {
		log.Fatal(err)
	}

	type notes struct{
		Dtl	[]note	`json:"hot"`
	}

	var hot notes
	err = json.Unmarshal(resp.Json, &hot)
	if err != nil {
		panic(err)
	}

	log.Println(hot)
}

