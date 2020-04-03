package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"

	"github.com/antonmashko/envconf"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type Config struct {
	PrometheusURL string `env:"PROMETHEUS_URL" required:"true"`
	Login         string `env:"PROMETHEUS_LOGIN" required:"true"`
	Password      string `env:"PROMETHEUS_PASSWORD" required:"true"`
}

var DefaultConfig = Config{}

type Response struct {
	StatusCode int
	Data       *map[string]interface{}
}

type MyEvent struct {
	Query string `json:"query"`
	Start int    `json:"start"`
	End   int    `json:"end"`
	Step  int    `json:"interval"`
}

func (e *MyEvent) validate() error {
	if e.Query == "" {
		return fmt.Errorf("query is required field")
	}
	if 0 >= e.Start || 0 >= e.End {
		return fmt.Errorf("start time and/or end time must be bigger than 0")
	}
	if e.Start > e.End {
		return fmt.Errorf("start time is bigger than the end time: %v > %v", e.Start, e.End)
	}
	if 0 >= e.Step {
		return fmt.Errorf("step must be bigger than 0: 0 >= %v", e.Step)
	}
	return nil
}

func init() {
	if err := envconf.Parse(&DefaultConfig); err != nil {
		panic(fmt.Errorf("cannot read config from env: %s", err))
	}
}

func fetch(conf MyEvent) (*Response, error) {
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
	fmt.Println("URL", req.URL.String())
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("cannot make request to Prometheus: %s", err)
	}
	defer resp.Body.Close()
	res := &map[string]interface{}{}
	if err := json.NewDecoder(resp.Body).Decode(res); err != nil {
		return nil, fmt.Errorf("cannot parse body from Prometheus: %s", err)
	}
	return &Response{
		StatusCode: resp.StatusCode,
		Data:       res,
	}, nil
}

func HandleRequest(ctx context.Context, body events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	var conf MyEvent
	if err := json.Unmarshal([]byte(body.Body), &conf); err != nil {
		return failed(http.StatusBadRequest, err), nil
	}
	if err := conf.validate(); err != nil {
		return failed(http.StatusBadRequest, err), nil
	}
	data, err := fetch(conf)
	if err != nil {
		return failed(http.StatusInternalServerError, err), nil
	}
	b, err := json.Marshal(data.Data)
	if err != nil {
		return failed(http.StatusInternalServerError, err), nil
	}
	return success(data.StatusCode, string(b)), nil
}

func failed(code int, err error) *events.APIGatewayProxyResponse {
	log.Printf("FAILED: %s\n", err)
	type jsonerror struct {
		Message string `json:"error"`
	}
	j := jsonerror{err.Error()}
	b, err := json.Marshal(j)
	if err != nil {
		return success(http.StatusInternalServerError, err.Error())
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
	lambda.Start(HandleRequest)
}
