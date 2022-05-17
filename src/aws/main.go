package main

import (
	"encoding/json"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	query "github.com/blamelesshq/proxy-function/query"
)

type QueryEvent struct {
	Query string `json:"query"`
	Start string `json:"start"`
	End   string `json:"end"`
	Step  string `json:"step"`
}

func main() {
	lambda.Start(HandleRequest)
}

// HandleRequest - Handles incoming requests
func HandleRequest(req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	searchQuery := req.QueryStringParameters["query"]
	start := req.QueryStringParameters["start"]
	end := req.QueryStringParameters["end"]
	step := req.QueryStringParameters["step"]
	accessToken := req.Headers["x-api-key"]

	result, status, err := query.Execute(searchQuery, start, end, step, accessToken)

	if err != nil {
		return apiResponse(status, err.Error()), err
	}

	return apiResponse(http.StatusOK, result), nil
}

func apiResponse(status int, body interface{}) *events.APIGatewayProxyResponse {
	resp := events.APIGatewayProxyResponse{
		Headers:    map[string]string{"Content-Type": "application/json"},
		StatusCode: status,
	}

	if body != nil {
		stringBody, _ := json.Marshal(body)
		resp.Body = string(stringBody)
	}

	return &resp
}
