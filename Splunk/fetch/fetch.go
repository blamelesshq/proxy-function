package fetch

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"sort"
	"strings"
	"time"

	. "github.com/ahmetb/go-linq/v3"
)

// func checkError(err error) {
// 	if err != nil {
// 		client := appinsights.NewTelemetryClient(os.Getenv("APPINSIGHTS_INSTRUMENTATIONKEY"))
// 		trace := appinsights.NewTraceTelemetry(err.Error(), appinsights.Error)
// 		trace.Timestamp = time.Now()
// 		client.Track(trace)
// 		// false indicates that we should have this handle the panic, and
// 		// not re-throw it.
// 		defer appinsights.TrackPanic(client, false)
// 		panic(err)
// 	}
// }

// func checkStringError(err string) {
// 	client := appinsights.NewTelemetryClient(os.Getenv("APPINSIGHTS_INSTRUMENTATIONKEY"))
// 	trace := appinsights.NewTraceTelemetry(err, appinsights.Error)
// 	trace.Timestamp = time.Now()
// 	client.Track(trace)
// 	// false indicates that we should have this handle the panic, and
// 	// not re-throw it.
// 	defer appinsights.TrackPanic(client, false)
// 	panic(err)
// }

// func handleRequestWithLog(h func(http.ResponseWriter, *http.Request)) http.HandlerFunc {
// 	return http.HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {
// 		startTime := time.Now()
// 		h(writer, request)
// 		duration := time.Now().Sub(startTime)
// 		client := appinsights.NewTelemetryClient(
// 			os.Getenv("APPINSIGHTS_INSTRUMENTATIONKEY"))
// 		trace := appinsights.NewRequestTelemetry(
// 			request.Method, request.URL.Path, duration, "200")
// 		trace.Timestamp = time.Now()
// 		client.Track(trace)
// 	})
// }

type FunctionObj struct {
	Route       string
	Url         string
	AccessToken string
}

type RouteConfigObj struct {
	Functions []FunctionObj
}

type Response struct {
	StatusCode int
	Data       *map[string]interface{}
}

type Fetch struct {
	Path        string
	Search      string
	Start       string
	End         string
	Url         string
	AccessToken string
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

	// fmt.Println(epoch)

	return fmt.Sprint(epoch)
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
			// fmt.Println("Res: " + res)
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

	// searchQuery := f.Search

	fmt.Println(searchQuery)

	payload := strings.NewReader("search=" + searchQuery + "&exec_mode=blocking")

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

	var sid Sid
	b, err := json.Marshal(res)
	if err != nil {
		checkError(err)
		return nil, fmt.Errorf("cannot parse body from Splunk: %s", err)
	}
	json.Unmarshal([]byte(string(b)), &sid)

	// fmt.Println(res)

	time.Sleep(1 * time.Second)

	req1, err1 := http.NewRequest(http.MethodGet, f.Url, nil)
	req1.URL.RawQuery = "output_mode=json&count=0"

	req1.URL.Path = "/services/search/jobs/" + sid.Sid + "/results"
	if err1 != nil {
		checkError(err1)
		return nil, fmt.Errorf("cannot create Splunk request: %s", err1)
	}

	req1.Header.Add("Authorization", "Bearer "+f.AccessToken)

	client1 := &http.Client{}
	resp1, err1 := client1.Do(req1)
	if err1 != nil {
		checkError(err1)
		return nil, fmt.Errorf("cannot make request to Splunk: %s", err1)
	}
	defer resp1.Body.Close()

	res1 := &map[string]interface{}{}
	json.NewDecoder(resp1.Body).Decode(res1)

	if resp1 == nil || resp1.StatusCode != 200 {
		jsonString2, _ := json.Marshal(res1)
		fmt.Println("Response: " + string(jsonString2))
		checkStringError("Unsuccessful response returned from server! Response:" + string(jsonString2))
		return nil, fmt.Errorf("%s", string(jsonString2))
	}

	results := (*res1)["results"].(([]interface{}))

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
		StatusCode: resp1.StatusCode,
		Data:       finalResult,
	}, nil
}

func NewFetch(values map[string]string) (*Fetch, error) {
	apiPath, ok := values["path"]
	if !ok {
		return nil, fmt.Errorf("empty path for ApiPath: %s", apiPath)
	}

	path, ok := values["api_path"]
	if !ok {
		return nil, fmt.Errorf("empty path for Splunk: %s", path)
	}

	path = "/services/search/jobs"

	search, ok := values["query"] //values["search"]
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

	var routeConfigObj RouteConfigObj

	err := json.Unmarshal([]byte(os.Getenv("RouteConfig")), &routeConfigObj)

	if err != nil {
		checkError(err)
		// fmt.Println(err)
	}

	var splunkUrl = From(routeConfigObj.Functions).Where(func(c interface{}) bool {
		// fmt.Println("Route: " + c.(FunctionObj).Route)
		return c.(FunctionObj).Route == "/api/fetch"
	}).Select(func(c interface{}) interface{} {
		// fmt.Print(c.(FunctionObj).Url)
		return c.(FunctionObj).Url
	}).First()

	splunkUrlRes := fmt.Sprintf("%v", splunkUrl)

	var splunkAccessToken = From(routeConfigObj.Functions).Where(func(c interface{}) bool {
		// fmt.Println("Route: " + c.(FunctionObj).Route)
		return c.(FunctionObj).Route == "/api/fetch"
	}).Select(func(c interface{}) interface{} {
		// fmt.Print(c.(FunctionObj).Url)
		return c.(FunctionObj).AccessToken
	}).First()

	splunkAccessTokenRes := fmt.Sprintf("%v", splunkAccessToken)

	return &Fetch{
		Path:        path,
		Search:      search,
		Start:       start,
		End:         end,
		Url:         splunkUrlRes,
		AccessToken: splunkAccessTokenRes,
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
