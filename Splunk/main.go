package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/blamelesshq/lambda-prometheus/fetch"
)

type FunctionObj struct {
	Route             string
	SplunkUrl         string
	SplunkAccessToken string
}

type RouteConfigObj struct {
	Functions []FunctionObj
}

func main() {
	listenAddr := ":8080"
	if val, ok := os.LookupEnv("FUNCTIONS_CUSTOMHANDLER_PORT"); ok {
		listenAddr = ":" + val
	}
	var routeConfigObj RouteConfigObj
	err := json.Unmarshal([]byte(os.Getenv("RouteConfig")), &routeConfigObj)

	if err != nil {
		fmt.Println(err)
	}

	for _, element := range routeConfigObj.Functions {
		// element is the element from someSlice for where we are
		http.HandleFunc(element.Route, fetch.HandleRequestAzure)
	}

	log.Printf("About to listen on %s. Go to https://127.0.0.1%s/", listenAddr, listenAddr)
	log.Fatal(http.ListenAndServe(listenAddr, nil))
}
