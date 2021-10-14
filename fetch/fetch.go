package fetch

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sort"
	"strings"
	"time"
)

type Response struct {
	StatusCode int
	Data       *map[string]interface{}
}

type Fetch struct {
	Path   string
	Search string
	Start  string
	End    string
}

type Result struct {
	Bltime  string
	Blvalue string
}

func contains(s []string, searchterm string) bool {
	for _, s := range s {
		if strings.Contains(s, searchterm) {
			return true
		}
	}
	return false
}

func convertDateTimeToEpoch(s string) string {
	fmt.Println("String123: " + s)
	thetime, e := time.Parse(time.RFC3339, s+"+00:00") //"2021-10-06T13:01:33+00:00"

	if e != nil {
		panic("Can't parse time format")
	}

	epoch := thetime.Unix()

	return fmt.Sprint(epoch)
}

func (f *Fetch) DoSplunk() (*Response, error) {

	epochStart := convertDateTimeToEpoch(f.Start)
	epochEnd := convertDateTimeToEpoch(f.End)

	fmt.Println(f.Search)
	parts := strings.Split(f.Search, "|")
	sort.Strings(parts)
	if !contains(parts, "fields") {
		f.Search = f.Search + "| fields bltime blvalue"
	}

	if !contains(parts, "rename") {
		res1 := &map[string]interface{}{"error": "blTime or blValues is not present in the query!", "description": "blTime, blValues must be present in the fields section of the query"}

		fmt.Println((*res1)["error"].(string))

		return &Response{
			StatusCode: 400,
			Data:       res1,
		}, nil
	}

	searchParts := strings.Split(f.Search, "|")
	searchQuery := ""

	for i, res := range searchParts {
		if i == 0 {
			searchQuery += res + " _indextime>=" + epochStart + " _indextime<" + epochEnd + "|"
		} else {
			if i+1 < len(searchParts) {
				searchQuery += res + "|"
			} else {
				searchQuery += res
			}
		}
	}

	fmt.Println(searchQuery)

	payload := strings.NewReader("search=" + searchQuery)

	client := &http.Client{}
	req, err := http.NewRequest(http.MethodPost, DefaultConfig.SplunkUrl, payload)
	req.URL.RawQuery = "output_mode=json"

	req.URL.Path = f.Path

	if err != nil {
		fmt.Println(err)
		return nil, fmt.Errorf("cannot make request to Splunk: %s", err)
	}
	req.Header.Add("Authorization", "Bearer "+DefaultConfig.SplunkAccessToken)
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("cannot make request to Splunk: %s", err)
	}
	defer resp.Body.Close()

	res := &map[string]interface{}{}
	if err := json.NewDecoder(resp.Body).Decode(res); err != nil {
		return nil, fmt.Errorf("cannot parse body from Splunk 11: %s", err)
	}

	var sid Sid
	b, err := json.Marshal(res)
	if err != nil {
		return nil, fmt.Errorf("cannot parse body from Prometheus 12: %s", err)
	}
	json.Unmarshal([]byte(string(b)), &sid)

	// fmt.Println(res)

	time.Sleep(1 * time.Second)

	req1, err1 := http.NewRequest(http.MethodGet, DefaultConfig.SplunkUrl, nil)
	req1.URL.RawQuery = "output_mode=json"

	req1.URL.Path = "/services/search/jobs/" + sid.Sid + "/results"
	if err1 != nil {
		return nil, fmt.Errorf("cannot create Splunk request: %s", err)
	}

	req1.Header.Add("Authorization", "Bearer "+DefaultConfig.SplunkAccessToken)

	client1 := &http.Client{}
	resp1, err1 := client1.Do(req1)
	if err1 != nil {
		return nil, fmt.Errorf("cannot make request to Splunk: %s", err)
	}
	defer resp1.Body.Close()

	res1 := &map[string]interface{}{}
	if err1 := json.NewDecoder(resp1.Body).Decode(res1); err1 != nil {
		return nil, fmt.Errorf("cannot parse body from Splunk 111: %s", err1)
	}

	results := (*res1)["results"].(([]interface{}))

	var finalResponse = "{ \"data\": { \"result\": [ { \"metric\": {}, \"values\": ["

	for i, res := range results {

		var result Result
		res12, _ := json.Marshal(res)
		if err != nil {
			return nil, fmt.Errorf("cannot parse body from Prometheus 12: %s", err)
		}
		json.Unmarshal([]byte(string(res12)), &result)

		finalResponse = finalResponse + "[ " + result.Bltime + ", \"" + result.Blvalue + "\"]"

		if i+1 < len(results) {
			finalResponse = finalResponse + ","
		}
	}

	finalResponse = finalResponse + "] } ], \"resultType\": \"matrix\"}, \"status\": \"success\"}"

	finalResult := &map[string]interface{}{}
	json.Unmarshal([]byte(finalResponse), &finalResult)

	return &Response{
		StatusCode: resp1.StatusCode,
		Data:       finalResult,
	}, nil
}

func NewFetch(values map[string]string) (*Fetch, error) {
	path, ok := values["api_path"]
	if !ok {
		return nil, fmt.Errorf("empty path for Splunk: %s", path)
	}

	search, ok := values["search"]
	if !ok {
		return nil, fmt.Errorf("empty search for Splunk: %s", search)
	}

	start, ok := values["start"]
	if !ok {
		return nil, fmt.Errorf("empty start for Splunk: %s", search)
	}

	end, ok := values["end"]
	if !ok {
		return nil, fmt.Errorf("empty end for Splunk: %s", search)
	}

	return &Fetch{
		Path:   path,
		Search: search,
		Start:  start,
		End:    end,
	}, nil
}

// func (f *Fetch) Do() (*Response, error) {
// 	req, err := http.NewRequest(http.MethodGet, DefaultConfig.SplunkUrl, nil)
// 	if err != nil {
// 		return nil, fmt.Errorf("cannot create Splunk request: %s", err)
// 	}

// 	req.Header.Add("Authorization", "Bearer "+DefaultConfig.SplunkAccessToken)

// 	req.URL.Path = f.Path
// 	// req.URL.RawQuery = f.Params
// 	fmt.Println("URL", req.URL.String())
// 	resp, err := http.DefaultClient.Do(req)
// 	if err != nil {
// 		return nil, fmt.Errorf("cannot make request to Prometheus: %s", err)
// 	}
// 	defer resp.Body.Close()
// 	res := &map[string]interface{}{}
// 	if err := json.NewDecoder(resp.Body).Decode(res); err != nil {
// 		return nil, fmt.Errorf("cannot parse body from Prometheus: %s", err)
// 	}
// 	return &Response{
// 		StatusCode: resp.StatusCode,
// 		Data:       res,
// 	}, nil
// }
