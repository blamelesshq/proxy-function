package fetch

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	ginadapter "github.com/awslabs/aws-lambda-go-api-proxy/gin"
	"github.com/gin-gonic/gin"
)

var ginLambda *ginadapter.GinLambda

type FunctionObj struct {
	Route       string
	Url         string
	AccessToken string
}

type RouteConfigObj struct {
	Functions []FunctionObj
}

func ProcessFetch(c *gin.Context) { //(int, string) {
	fetch, err := NewFetch(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
	}
	resp, err := fetch.Do()
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
	}
	b, err := json.Marshal(resp.Data)
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
	}
	fmt.Println(b)
	c.JSON(http.StatusOK, string(b))
}

// HandleRequestAWS handler for AWS lambda function
func HandleRequestAWS(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var routeConfigObj RouteConfigObj
	err := json.Unmarshal([]byte(os.Getenv("RouteConfig")), &routeConfigObj)

	if err != nil {
		fmt.Println(err)
	}

	if ginLambda == nil {
		// stdout and stderr are sent to AWS CloudWatch Logs
		log.Printf("Gin cold start")
		r := gin.Default()

		for _, element := range routeConfigObj.Functions {
			// element is the element from someSlice for where we are
			r.GET(element.Route, ProcessFetch)
			// http.HandleFunc(element.Route, fetch.HandleRequestAzure)
		}
		// r.GET("/pets", getPets)
		// r.GET("/pets/:id", getPet)
		// r.POST("/pets", createPet)

		ginLambda = ginadapter.New(r)
	}

	// code, body := ProcessFetch(request.QueryStringParameters)
	// return &events.APIGatewayProxyResponse{
	// 	StatusCode: code,
	// 	Body:       body,
	// }, nil

	return ginLambda.ProxyWithContext(ctx, request)
}
