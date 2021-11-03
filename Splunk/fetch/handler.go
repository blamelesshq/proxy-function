package fetch

import (
	"encoding/json"
	"net/http"
)

type Sid struct {
	Sid string
}

func ProcessFetch(params map[string]string) (int, string) {
	fetch, err := NewFetch(params)
	if err != nil {
		return http.StatusBadRequest, err.Error()
	}
	resp, err := fetch.DoSplunk()
	if err != nil {
		return http.StatusInternalServerError, err.Error()
	}
	b, err := json.Marshal(resp.Data)
	if err != nil {
		return http.StatusInternalServerError, err.Error()
	}
	return resp.StatusCode, string(b)
}

func HandleRequestAzure(w http.ResponseWriter, r *http.Request) {
	// prepare params from a query string for fetch
	params := map[string]string{}
	for k, v := range r.URL.Query() {
		params[k] = v[0]
	}

	params["path"] = r.URL.Path

	code, body := ProcessFetch(params)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write([]byte(body))
}
