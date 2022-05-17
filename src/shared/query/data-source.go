package query

import config "github.com/blamelesshq/proxy-function/config"

const SPLUNK_DATA_SOURCE = "splunk"

// DataSource - Interface for common data source methods
type DataSource interface {
	Validate(q *Query) error
	Execute(q *Query) (interface{}, error)
	Transform(results interface{}) (interface{}, error)
}

func GetDataSource(config *config.Config) DataSource {
	if config.Type == SPLUNK_DATA_SOURCE {
		return Splunk{}
	} else {
		return Prometheus{}
	}
}
