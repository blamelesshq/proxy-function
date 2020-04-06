package main

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/antonmashko/envconf"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws/session"
	_ "github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/kms"
	_ "github.com/aws/aws-sdk-go/service/kms"
)

type Config struct {
	PrometheusURL string `env:"PROMETHEUS_URL" required:"true"`
	Login         string `env:"PROMETHEUS_LOGIN" required:"true"`
	Password      string `env:"PROMETHEUS_PASSWORD" required:"true"`
}

var DefaultConfig = Config{}

func init() {
	if err := envconf.Parse(&DefaultConfig); err != nil {
		panic(fmt.Errorf("cannot read config from env: %s", err))
	}
	kmsClient := kms.New(session.New())
	// get login
	l, err := base64.StdEncoding.DecodeString(DefaultConfig.Login)
	if err != nil {
		panic(err)
	}
	input := &kms.DecryptInput{
		CiphertextBlob: l,
	}
	response, err := kmsClient.Decrypt(input)
	if err != nil {
		panic(err)
	}
	DefaultConfig.Login = string(response.Plaintext[:])
	// get password
	p, err := base64.StdEncoding.DecodeString(DefaultConfig.Password)
	if err != nil {
		panic(err)
	}
	input = &kms.DecryptInput{
		CiphertextBlob: p,
	}
	response, err = kmsClient.Decrypt(input)
	if err != nil {
		panic(err)
	}
	DefaultConfig.Password = string(response.Plaintext[:])
}

func HandleRequest(ctx context.Context, body events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	fetch, err := NewFetch(body.QueryStringParameters)
	if err != nil {
		return failed(http.StatusBadRequest, err), nil
	}
	data, err := fetch.Do()
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
