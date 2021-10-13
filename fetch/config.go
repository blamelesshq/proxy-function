package fetch

import (
	"os"
)

type Config struct {
	SplunkUrl         string `env:"PROMETHEUS_URL" required:"true"`
	SplunkAccessToken string `env:"PROMETHEUS_LOGIN" required:"true"`
}

var DefaultConfig = Config{}

func init() {
	DefaultConfig.SplunkUrl = os.Getenv("SPLUNK_URL")
	DefaultConfig.SplunkAccessToken = os.Getenv("SPLUNK_ACCESS_TOKEN")
}
