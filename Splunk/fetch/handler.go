package fetch

import (
	"encoding/json"
	"net/http"
	"os"
	"time"

	"github.com/microsoft/ApplicationInsights-Go/appinsights"
)

type Sid struct {
	Sid string
}

func checkStringError(err string) {
	client := appinsights.NewTelemetryClient(os.Getenv("APPINSIGHTS_INSTRUMENTATIONKEY"))
	trace := appinsights.NewTraceTelemetry(err, appinsights.Error)
	trace.Timestamp = time.Now()
	client.Track(trace)
	// false indicates that we should have this handle the panic, and
	// not re-throw it.
	defer appinsights.TrackPanic(client, false)
	panic(err)
}

func checkError(err error) {
	if err != nil {
		client := appinsights.NewTelemetryClient(os.Getenv("APPINSIGHTS_INSTRUMENTATIONKEY"))
		trace := appinsights.NewTraceTelemetry(err.Error(), appinsights.Error)
		trace.Timestamp = time.Now()
		client.Track(trace)
		// false indicates that we should have this handle the panic, and
		// not re-throw it.
		defer appinsights.TrackPanic(client, false)
		panic(err)
	}
}

func ProcessFetch(params map[string]string) (int, string) {
	fetch, err := NewFetch(params)
	if err != nil {
		checkError(err)
		return http.StatusBadRequest, err.Error()
	}
	resp, err := fetch.DoSplunk()
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
