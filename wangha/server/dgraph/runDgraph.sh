#! /bin/sh
dgraph zero
dgraph alpha --lru_mb 2048 --zero localhost:5080
dgraph-ratel

