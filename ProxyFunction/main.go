package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	fetch "github.com/blamelesshq/lambda-prometheus/fetch"
)

func main() {
	listenAddr := ":8080"
	if val, ok := os.LookupEnv("FUNCTIONS_CUSTOMHANDLER_PORT"); ok {
		listenAddr = ":" + val
	}
	var routeConfigObj fetch.RouteConfigObj
	err := json.Unmarshal([]byte(os.Getenv("RouteConfig")), &routeConfigObj)

	if err != nil {
		fmt.Println(err)
	}

	for _, element := range routeConfigObj.Functions {
		http.HandleFunc(element.Route, fetch.HandleRequestAzure)
	}

	log.Printf("About to listen on %s. Go to https://127.0.0.1%s/", listenAddr, listenAddr)
	log.Fatal(http.ListenAndServe(listenAddr, nil))
}
