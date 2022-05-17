package query

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sort"
	"strings"
)

type Splunk struct{}

func (s Splunk) Validate(q *Query) error {
	contains := func(arr []string, searchTerm string) bool {
		for _, s := range arr {
			if strings.Contains(s, searchTerm) {
				return true
			}
		}
		return false
	}

	parts := strings.Split(q.Query, "|")
	// ??
	sort.Strings(parts)
	if !contains(parts, "fields") {
		q.Query = q.Query + "| fields bltime blvalue"
	}

	if !contains(parts, "rename") {
		return fmt.Errorf("blTime or blValues is not present in the query!")
	}

	return nil
}

func (s Splunk) Execute(q *Query) (interface{}, error) {

	searchParts := strings.Split(q.Query, "|")
	searchQuery := ""

	for i, res := range searchParts {
		if i == 0 {
			if strings.Contains(res, "_indextime>") && strings.Contains(res, "_indextime<") {
				searchQuery += res + "|"
			} else if strings.Contains(res, "_idextime>") && !strings.Contains(res, "_indextime<") {
				searchQuery += res + " _indextime<" + q.End + "|"
			} else if !strings.Contains(res, "_idextime>") && strings.Contains(res, "_indextime<") {
				searchQuery += res + " _indextime>=" + q.Start + "|"
			} else {
				searchQuery += res + " _indextime>=" + q.Start + " _indextime<" + q.End + "|"
			}
		} else {
			if i+1 < len(searchParts) {
				searchQuery += res + "|"
			} else {
				searchQuery += res
			}
		}
	}

	payload := strings.NewReader("search=" + searchQuery + "&exec_mode=oneshot&timeout=30")

	client := &http.Client{}
	req, err := http.NewRequest(http.MethodPost, q.config.Url, payload)
	req.URL.RawQuery = "output_mode=json"

	if err != nil {
		return nil, fmt.Errorf("cannot make request to Splunk: %s", err)
	}
	req.Header.Add("Authorization", "Bearer "+q.AccessToken)
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("cannot make request to Splunk: %s", err)
	}

	defer resp.Body.Close()

	var result interface{}
	if err := json.NewDecoder(resp.Body).Decode(result); err != nil {
		return nil, fmt.Errorf("cannot parse body from Splunk: %s", err)
	}

	if resp == nil || resp.StatusCode != 200 {
		body, _ := json.Marshal(result)
		return nil, fmt.Errorf("Unsuccessful response returned from server! Response: %s", string(body))
	}

	return result, nil
}

type splunkResponse struct {
	result []splunkResponseResult
}

type splunkResponseResult struct {
	Bltime  string
	Blvalue string
}

func (s Splunk) Transform(results interface{}) (interface{}, error) {

	response := results.(splunkResponse)

	values := make([]map[string]string, len(response.result))
	for i, r := range response.result {
		values[i] = map[string]string{r.Bltime: r.Blvalue}
	}

	return QueryResponse{
		Status: "success",
		Data: QueryResponseData{
			Result: []QueryResponseDataResult{
				QueryResponseDataResult{
					Values: values,
				},
			},
			ResultType: "matrix",
		},
	}, nil
}
