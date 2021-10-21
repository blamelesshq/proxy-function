package fetch

import (
	"encoding/json"
	"net/http"
)

func ProcessFetch(params map[string]string) (int, string) {
	fetch, err := NewFetch(params)
	if err != nil {
		return http.StatusBadRequest, err.Error()
	}
	resp, err := fetch.Do()
	if err != nil {
		return http.StatusInternalServerError, err.Error()
	}
	b, err := json.Marshal(resp.Data)
	if err != nil {
		return http.StatusInternalServerError, err.Error()
	}
	return resp.StatusCode, string(b)
}

// // HandleRequestGCP handler for GCP functions
// func HandleRequestGCP(w http.ResponseWriter, r *http.Request) {
// 	// prepare params from a query string for fetch
// 	params := map[string]string{}
// 	for k, v := range r.URL.Query() {
// 		params[k] = v[0]
// 	}
// 	code, body := ProcessFetch(params)
// 	w.Header().Set("Content-Type", "application/json")
// 	w.WriteHeader(code)
// 	w.Write([]byte(body))
// }

func HandleRequestAzure(w http.ResponseWriter, r *http.Request) {
	// prepare params from a query string for fetch
	params := map[string]string{}
	for k, v := range r.URL.Query() {
		params[k] = v[0]
	}
	code, body := ProcessFetch(params)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write([]byte(body))
}

// HandleRequestAWS handler for AWS lambda function
// func HandleRequestAWS(ctx context.Context, request events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
// 	code, body := ProcessFetch(request.QueryStringParameters)
// 	return &events.APIGatewayProxyResponse{
// 		StatusCode: code,
// 		Body:       body,
// 	}, nil
// }
