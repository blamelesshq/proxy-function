package query

import (
	"encoding/json"
	"net/http"

	_ "github.com/GoogleCloudPlatform/functions-framework-go/funcframework"

	query "github.com/blamelesshq/proxy-function/query"
)

// Where is main()?
// GCP functions do not require a main function

// HandleQuery - Entrypoint for the Google Cloud function
func HandleQuery(w http.ResponseWriter, r *http.Request) {

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
