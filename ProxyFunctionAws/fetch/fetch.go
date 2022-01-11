package fetch

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"

	"github.com/gin-gonic/gin"
)

type Response struct {
	StatusCode int
	Data       *map[string]interface{}
}

type Fetch struct {
	Path   string
	Params string
}

func NewFetch(c *gin.Context) (*Fetch, error) {

	path := c.Query("api_path")
	if c.Query("api_path") != "" {
		// path := c.Query("api_path")
	} else {
		return nil, fmt.Errorf("empty path for Prometheus: %s", path)
	}

	params := url.Values{}
	for k, v := range c.Request.URL.Query() {
		if k == "api_path" {
			continue
		}
		params.Add(k, v[0])
	}
	return &Fetch{
		Path:   path,
		Params: params.Encode(),
	}, nil
}

func (f *Fetch) Do() (*Response, error) {
	req, err := http.NewRequest(http.MethodGet, DefaultConfig.PrometheusURL, nil)
	if err != nil {
		return nil, fmt.Errorf("cannot create Prometheus request: %s", err)
	}
	req.SetBasicAuth(DefaultConfig.Login, DefaultConfig.Password)
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
