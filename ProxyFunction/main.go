package main

import (
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/blamelesshq/lambda-prometheus/fetch"
)

func main() {
	switch cloudEnv := os.Getenv("CLOUD_ENVIRONMENT"); cloudEnv {
	case "Azure":
		fetch.HandleRequestAzure()
	case "AWS":
		lambda.Start(fetch.HandleRequestAWS)
	default:
		// freebsd, openbsd,
		// plan9, windows...
		fmt.Println("GCP")
	}
}
