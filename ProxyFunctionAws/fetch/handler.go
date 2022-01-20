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

func ProcessFetch(params map[string]string) (int, string) {
	fetch, err := NewFetch(params)
	if err != nil {
		checkError(err)
		return http.StatusBadRequest, err.Error()
	}

	resp, err := func() (*Response, error) {
		if fetch.Type == "Splunk" {
			return fetch.DoSplunk()
		} else {
			return fetch.Do()
		}
	}()

	if err != nil {
		checkError(err)
		return http.StatusInternalServerError, err.Error()
	}
	b, err := json.Marshal(resp.Data)
	if err != nil {
		checkError(err)
		return http.StatusInternalServerError, err.Error()
	}
	return resp.StatusCode, string(b)
}

func HandleRequestAzure(w http.ResponseWriter, r *http.Request) {
	// prepare params from a query string for fetch
	params := map[string]string{}
	for k, v := range r.URL.Query() {
		params[k] = v[0]
	}

	params["path"] = r.URL.Path

	code, body := ProcessFetch(params)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	w.Write([]byte(body))
}

func ProcessFetchAws(c *gin.Context) { //(int, string) {
	fetch, err := NewFetchAws(c)
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
	}

	resp, err := func() (*Response, error) {
		if fetch.Type == "Splunk" {
			return fetch.DoSplunk()
		} else {
			return fetch.DoAws()
		}
	}()
	// resp, err := fetch.DoAws()
	if err != nil {
		c.JSON(http.StatusBadRequest, err.Error())
		return
	}
	b, err := json.Marshal(resp.Data)
	if err != nil {
		c.JSON(http.StatusBadRequest, err.Error())
		return
	}

	var raw map[string]interface{}
	if err := json.Unmarshal(b, &raw); err != nil {
		c.JSON(http.StatusBadRequest, err.Error())
		return
	}
	fmt.Println(raw)
	c.JSON(http.StatusOK, raw)
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
			r.GET(element.Route, ProcessFetchAws)
		}

		ginLambda = ginadapter.New(r)
	}

	return ginLambda.ProxyWithContext(ctx, request)
}
