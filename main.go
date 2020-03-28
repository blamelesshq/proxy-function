package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"

	"github.com/antonmashko/envconf"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type Config struct {
	PrometheusURL string `env:"PROMETHEUS_URL" required:"true"`
	RestoURL      string `env:"RESTO_URL" required:"true"`
	Login         string `env:"PROMETHEUS_LOGIN" required:"true"`
	Password      string `env:"PROMETHEUS_PASSWORD" required:"true"`
	RestoToken    string `env:"RESTO_AUTH_TOKEN" required:"true"`
}

var DefaultConfig = Config{}

type Result struct {
	Values [][]json.Number `json:"values"`
}

type Data struct {
	Result []Result `json:"result"`
}

type PrometheusResponse struct {
	Data Data `json:"data"`
}

type SliRawData struct {
	SliID int     `json:"sliId"`
	Value float64 `json:"value"`
	Start uint64  `json:"start"`
	End   uint64  `json:"end"`
}

type RestoRequest struct {
	Model *SliRawData `json:"model"`
}

type RestoResponse struct {
	ID        int `json:"id"`
	CreatedAt int `json:"createdAt"`
	OrgID     int `json:"orgId"`
	SliID     int `json:"sliId"`
	Value     int `json:"value"`
	Start     int `json:"start"`
	End       int `json:"end"`
}

type MyEvent struct {
	Query string `json:"query"`
	Start int    `json:"start"`
	End   int    `json:"end"`
	Step  int    `json:"interval"`
	SliID int    `json:"sliId"`
}

func init() {
	if err := envconf.Parse(&DefaultConfig); err != nil {
		panic(fmt.Errorf("cannot read config from env: %s", err))
	}
}

func getPrometheusRawData(conf MyEvent) (*PrometheusResponse, error) {
	req, err := http.NewRequest(http.MethodGet, DefaultConfig.PrometheusURL, nil)
	if err != nil {
		return nil, fmt.Errorf("cannot create Prometheus request: %s", err)
	}
	req.SetBasicAuth(DefaultConfig.Login, DefaultConfig.Password)
	q := req.URL.Query()
	q.Add("query", conf.Query)
	q.Add("start", strconv.Itoa(conf.Start))
	q.Add("end", strconv.Itoa(conf.End))
	q.Add("step", strconv.Itoa(conf.Step))
	req.URL.RawQuery = q.Encode()
	resp, err := http.DefaultClient.Do(req)
	fmt.Println("URL", req.URL.String())
	if err != nil {
		return nil, fmt.Errorf("cannot make request to Prometheus: %s", err)
	}
	defer resp.Body.Close()
	res := &PrometheusResponse{}
	if err := json.NewDecoder(resp.Body).Decode(res); err != nil {
		return nil, fmt.Errorf("cannot parse body from Prometheus: %s", err)
	}
	return res, nil
}

func sendDataToResto(data *RestoRequest) (*RestoResponse, error) {
	d, err := json.Marshal(data)
	if err != nil {
		return nil, fmt.Errorf("cannot encode to json: %s", err)
	}
	req, err := http.NewRequest(http.MethodPost, DefaultConfig.RestoURL, bytes.NewBuffer(d))
	if err != nil {
		return nil, fmt.Errorf("cannot create request to Resto: %s", err)
	}
	req.Header.Add("Content-Type", "application/json")
	req.Header.Add("Authorization", "Bearer "+DefaultConfig.RestoToken)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("cannot make make request to Resto: %s", err)
	}
	defer resp.Body.Close()
	res := &RestoResponse{}
	if err := json.NewDecoder(resp.Body).Decode(res); err != nil {
		return nil, fmt.Errorf("cannot parse body from Resto: %s", err)
	}
	return res, nil
}

func convertData(res *PrometheusResponse, conf MyEvent) (*RestoRequest, error) {
	if len(res.Data.Result) == 0 {
		return nil, fmt.Errorf("we got empty result from Prometheus")
	}
	r := res.Data.Result[0]
	if len(r.Values) == 0 {
		return nil, fmt.Errorf("we got empty values from Prometheus")
	}
	lastData := r.Values[0]
	if len(lastData) != 2 {
		return nil, fmt.Errorf("invalid data format from Prometheus")
	}
	time, err := lastData[0].Int64()
	if err != nil {
		return nil, fmt.Errorf("invalid TIME format from Prometheus")
	}
	value, err := lastData[1].Float64()
	if err != nil {
		return nil, fmt.Errorf("invalid VALUE format from Prometheus")
	}
	return &RestoRequest{
		Model: &SliRawData{
			SliID: conf.SliID,
			Start: uint64(time),
			End:   uint64(time + int64(conf.Step)),
			Value: value,
		},
	}, nil
}

func fetchData(conf MyEvent) (*RestoResponse, error) {
	rawData, err := getPrometheusRawData(conf)
	if err != nil {
		return nil, err
	}
	_, err = convertData(rawData, conf)
	if err != nil {
		return nil, err
	}
	// restoResp, err := sendDataToResto(restoReqData)
	// if err != nil {
	// 	return nil, err
	// }
	restoResp := &RestoResponse{
		ID:        1,
		CreatedAt: 1,
		OrgID:     1,
		SliID:     1,
		Value:     100,
		Start:     121314112,
		End:       121314212,
	}
	return restoResp, err
}

func HandleRequest(ctx context.Context, body events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	var conf MyEvent
	if err := json.Unmarshal([]byte(body.Body), &conf); err != nil {
		return failed(http.StatusBadRequest, err), nil
	}
	data, err := fetchData(conf)
	if err != nil {
		return failed(http.StatusInternalServerError, err), nil
	}
	b, err := json.Marshal(data)
	if err != nil {
		return failed(http.StatusInternalServerError, err), nil
	}
	return success(http.StatusOK, string(b)), nil
}

func failed(code int, err error) *events.APIGatewayProxyResponse {
	type jsonerror struct {
		Message string `json:"error"`
	}
	j := jsonerror{err.Error()}
	b, err := json.Marshal(j)
	if err != nil {
		return nil
	}
	return success(code, string(b))
}

func success(code int, body string) *events.APIGatewayProxyResponse {
	return &events.APIGatewayProxyResponse{
		StatusCode: code,
		Body:       body,
	}
}

func main() {
	// uncomment for local test
	// res, err := HandleRequest(context.Background(), MyEvent{
	// 	Query: "up",
	// 	Start: 1585313003,
	// 	End:   1585313123,
	// 	Step:  15,
	// 	SliID: 1,
	// })
	// fmt.Printf("%+v", res)
	// fmt.Println("error:", err)
	lambda.Start(HandleRequest)
}
