package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	query "github.com/blamelesshq/proxy-function/query"
)

func main() {
	listenAddr := ":8080"
	if val, ok := os.LookupEnv("FUNCTIONS_CUSTOMHANDLER_PORT"); ok {
		listenAddr = ":" + val
	}
	http.HandleFunc("/api/HttpExample", HandleRequest)
	log.Printf("About to listen on %s", listenAddr)
	log.Fatal(http.ListenAndServe(listenAddr, nil))
}

// HandleRequest - Handles incoming requests
func HandleRequest(w http.ResponseWriter, r *http.Request) {
	searchQuery := r.URL.Query().Get("query")
	start := r.URL.Query().Get("start")
	end := r.URL.Query().Get("end")
	step := r.URL.Query().Get("step")
	accessToken := r.Header.Get("x-api-key")

	result, status, err := query.Execute(searchQuery, start, end, step, accessToken)

	if err != nil {
		http.Error(w, err.Error(), status)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
