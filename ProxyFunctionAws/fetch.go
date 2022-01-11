package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
)

type Response struct {
	StatusCode int
	Data       *map[string]interface{}
}

type Fetch struct {
	Path   string
	Params string
}

func NewFetch(values map[string]string) (*Fetch, error) {
	path, ok := values["api_path"]
	if !ok {
		return nil, fmt.Errorf("empty path for Prometheus: %s", path)
	}
	params := url.Values{}
	for k, v := range values {
		if k == "api_path" {
			continue
		}
		params.Add(k, v)
	}
	return &Fetch{
		Path:   path,
		Params: params.Encode(),
	}, nil
}

func (f *Fetch) Do() (*Response, error) {
	req, err := http.NewRequest(http.MethodGet, os.Getenv("PrometheusURL") /*DefaultConfig.PrometheusURL*/, nil)
	if err != nil {
		return nil, fmt.Errorf("cannot create Prometheus request: %s", err)
	}
	req.SetBasicAuth(os.Getenv("Login") /*DefaultConfig.Login*/, os.Getenv("Password") /*DefaultConfig.Password*/)
	req.URL.Path = f.Path
	req.URL.RawQuery = f.Params
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
