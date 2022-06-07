package query

import (
	"fmt"
	"net/http"

	"github.com/blamelesshq/proxy-function/config"
)

const SPLUNK_TYPE = "splunk"

// Query - Input parameters for a query
type Query struct {
	Query       string
	Start       string
	End         string
	Step        string
	AccessToken string
	config      *config.Config
}

func newQuery(query string, start string, end string, step string, accessToken string, config *config.Config) (*Query, error) {

	if query == "" {
		return nil, fmt.Errorf("empty query variable")
	}

	if start == "" {
		return nil, fmt.Errorf("empty start variable")
	}

	if end == "" {
		return nil, fmt.Errorf("empty end variable")
	}

	return &Query{
		Query:       query,
		Start:       start,
		End:         end,
		Step:        step,
		AccessToken: accessToken,
		config:      config,
	}, nil
}

// Execute - Runs the query workflow and returns the query results, http status code, and errors if there are any
func Execute(query string, start string, end string, step string, accessToken string) (interface{}, int, error) {

	config, err := config.NewConfig()

	if err != nil {
		return nil, http.StatusInternalServerError, err
	}

	dataSource := GetDataSource(config)

	q, err := newQuery(query, start, end, step, accessToken, config)

	if err != nil {
		return nil, http.StatusBadRequest, err
	}

	err = dataSource.Validate(q)

	if err != nil {
		return nil, http.StatusBadRequest, err
	}

	results, err := dataSource.Execute(q)

	if err != nil {
		return nil, http.StatusInternalServerError, err
	}

	results, err = dataSource.Transform(results)

	if err != nil {
		return nil, http.StatusInternalServerError, err
	}

	return results, http.StatusOK, nil
}
