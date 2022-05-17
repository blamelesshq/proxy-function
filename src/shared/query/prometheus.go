package query

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/url"
)

// Prometheus - Prometheus data source
type Prometheus struct{}

func (p Prometheus) encode(q *Query) string {
	return url.Values{
		"query": []string{q.Query},
		"start": []string{q.Start},
		"end":   []string{q.End},
		"step":  []string{q.Step},
	}.Encode()
}

// Validate - Validates Prometheus query
func (p Prometheus) Validate(q *Query) error {
	return nil
}

// Execute - Executes Prometheus query
func (p Prometheus) Execute(q *Query) (interface{}, error) {

	req, err := http.NewRequest(http.MethodGet, q.config.Url, nil)
	if err != nil {
		return nil, fmt.Errorf("cannot create Prometheus request: %s", err)
	}

	req.SetBasicAuth(q.config.UserName, q.config.Password)
	req.URL.Path = q.config.Url
	req.URL.RawQuery = p.encode(q)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("cannot make request to Prometheus: %s", err)
	}

	defer resp.Body.Close()

	var data interface{}
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		log.Printf("request: %s%s?%s", req.URL.Host, req.URL.RawPath, req.URL.RawQuery)
		return nil, fmt.Errorf("cannot parse body from Prometheus: %s", err)
	}

	return data, nil
}

// Transform - Transforms data source responses
func (p Prometheus) Transform(result interface{}) (interface{}, error) {
	return result, nil
}
