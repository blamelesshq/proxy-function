package fetch

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"sort"
	"strings"

	. "github.com/ahmetb/go-linq/v3"
)

func contains(s []string, searchterm string) bool {
	for _, s := range s {
		if strings.Contains(s, searchterm) {
			return true
		}
	}
	return false
}

func (f *Fetch) DoSplunk() (*Response, error) {

	epochStart := f.Start //convertDateTimeToEpoch(f.Start)
	epochEnd := f.End     //convertDateTimeToEpoch(f.End)
	// fmt.Println(f.Search)
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
			if strings.Contains(res, "_indextime>") && strings.Contains(res, "_indextime<") {
				searchQuery += res + "|"
			} else if strings.Contains(res, "_idextime>") && !strings.Contains(res, "_indextime<") {
				searchQuery += res + " _indextime<" + epochEnd + "|"
			} else if !strings.Contains(res, "_idextime>") && strings.Contains(res, "_indextime<") {
				searchQuery += res + " _indextime>=" + epochStart + "|"
			} else {
				searchQuery += res + " _indextime>=" + epochStart + " _indextime<" + epochEnd + "|"
			}
		} else {
			if i+1 < len(searchParts) {
				searchQuery += res + "|"
			} else {
				searchQuery += res
			}
		}
	}

	// fmt.Println(searchQuery)

	payload := strings.NewReader("search=" + searchQuery + "&exec_mode=oneshot&timeout=30")

	client := &http.Client{}
	req, err := http.NewRequest(http.MethodPost, f.Url, payload)
	req.URL.RawQuery = "output_mode=json"

	req.URL.Path = f.Path

	if err != nil {
		checkError(err)
		return nil, fmt.Errorf("cannot make request to Splunk: %s", err)
	}
	req.Header.Add("Authorization", "Bearer "+f.AccessToken)
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")

	resp, err := client.Do(req)
	if err != nil {
		checkError(err)
		return nil, fmt.Errorf("cannot make request to Splunk: %s", err)
	}

	defer resp.Body.Close()

	res := &map[string]interface{}{}
	if err := json.NewDecoder(resp.Body).Decode(res); err != nil {
		checkError(err)
		fmt.Errorf("cannot make request to Splunk: %s", err)
		return nil, fmt.Errorf("cannot parse body from Splunk: %s", err)
	}

	fmt.Println(resp.StatusCode)
	if resp == nil || resp.StatusCode != 200 {
		jsonString2, _ := json.Marshal(res)
		fmt.Println("Response: " + string(jsonString2))
		checkStringError("Unsuccessful response returned from server! Response:" + string(jsonString2))
		return nil, fmt.Errorf("%s", string(jsonString2))
	}

	results := (*res)["results"].(([]interface{}))

	var finalResponse = "{ \"data\": { \"result\": [ { \"metric\": {}, \"values\": ["

	for i, res := range results {

		var result Result
		res12, _ := json.Marshal(res)
		if err != nil {
			checkError(err)
			return nil, fmt.Errorf("cannot parse body from Splunk: %s", err)
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
		StatusCode: resp.StatusCode,
		Data:       finalResult,
	}, nil
}

func (f *Fetch) Do() (*Response, error) {
	req, err := http.NewRequest(http.MethodGet, f.Url, nil)
	if err != nil {
		return nil, fmt.Errorf("cannot create Prometheus request: %s", err)
	}
	req.SetBasicAuth(f.Login, f.Password)
	req.URL.Path = f.Path
	req.URL.RawQuery = f.Params
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		checkError(err)
		return nil, fmt.Errorf("cannot make request to Prometheus: %s", err)
	}
	defer resp.Body.Close()
	res := &map[string]interface{}{}
	fmt.Println(resp)
	if err := json.NewDecoder(resp.Body).Decode(res); err != nil {
		checkError(err)
		return nil, fmt.Errorf("cannot parse body from Prometheus: %s", err)
	}
	return &Response{
		StatusCode: resp.StatusCode,
		Data:       res,
	}, nil
}

func NewFetch(values map[string]string) (*Fetch, error) {

	apiPath, ok := values["path"]
	if !ok {
		return nil, fmt.Errorf("empty path for ApiPath: %s", apiPath)
	}

	path, ok := values["api_path"]
	if !ok {
		return nil, fmt.Errorf("empty path api_path")
	}

	search, ok := values["query"] //values["search"]
	if !ok {
		return nil, fmt.Errorf("empty search: %s", search)
	}

	start, ok := values["start"]
	if !ok {
		return nil, fmt.Errorf("empty start: %s", search)
	}

	end, ok := values["end"]
	if !ok {
		return nil, fmt.Errorf("empty end: %s", search)
	}

	var routeConfigObj RouteConfigObj

	err := json.Unmarshal([]byte(os.Getenv("RouteConfig")), &routeConfigObj)

	if err != nil {
		checkError(err)
	}

	var funcInfo = From(routeConfigObj.Functions).Where(func(c interface{}) bool {
		return c.(FunctionObj).Route == apiPath
	}).Select(func(c interface{}) interface{} {
		return map[string]interface{}{
			"Url":         c.(FunctionObj).Url,
			"AccessToken": c.(FunctionObj).AccessToken,
			"Login":       c.(FunctionObj).Login,
			"Password":    c.(FunctionObj).Password,
			"Type":        c.(FunctionObj).Type,
		}
	}).First().(map[string]interface{})

	params := url.Values{}
	for k, v := range values {
		if k == "api_path" {
			if funcInfo["Type"].(string) == "Splunk" {
				path = "/services/search/jobs"
			}
			continue
		}
		params.Add(k, v)
	}

	return &Fetch{
		Path:        path,
		Search:      search,
		Start:       start,
		End:         end,
		Url:         funcInfo["Url"].(string),
		AccessToken: funcInfo["AccessToken"].(string),
		Login:       funcInfo["Login"].(string),
		Password:    funcInfo["Password"].(string),
		Type:        funcInfo["Type"].(string),
		Params:      params.Encode(),
	}, nil
}
