package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/blamelesshq/lambda-prometheus/fetch"
)

func main() {
	lambda.Start(fetch.HandleRequestAWS)
}
