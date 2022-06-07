package config

import (
	"fmt"
	"os"
	"strings"
)

// Config - Represents configuration neccessary to execute the function
type Config struct {
	Url         string
	AccessToken string
	UserName    string
	Password    string
	Type        string
}

// NewConfig - Creates a new Config
func NewConfig() (*Config, error) {

	url := os.Getenv("DATA_SOURCE_URL")
	userName := os.Getenv("DATA_SOURCE_USERNAME")
	password := os.Getenv("DATA_SOURCE_PASSWORD")
	accessToken := os.Getenv("FUNCTION_ACCESS_TOKEN")
	functionType := os.Getenv("FUNCTION_TYPE")

	if url == "" {
		return nil, fmt.Errorf("missing function configuration: DATA_SOURCE_URL")
	}

	if functionType == "" {
		return nil, fmt.Errorf("missing function configuration: FUNCTION_TYPE")
	}

	functionType = strings.ToLower(functionType)

	if functionType != "prometheus" && functionType != "splunk" {
		return nil, fmt.Errorf("invalid FUNCTION_TYPE value: %s. Valid Values: prometheus|splunk", functionType)
	}

	return &Config{
		Url:         url,
		AccessToken: accessToken,
		UserName:    userName,
		Password:    password,
		Type:        functionType,
	}, nil
}
