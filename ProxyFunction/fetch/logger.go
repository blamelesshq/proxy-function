package fetch

import (
	"os"
	"time"

	"github.com/microsoft/ApplicationInsights-Go/appinsights"
)

func checkStringError(err string) {
	cloudProvider := os.Getenv("CLOUD_PROVIDER")
	if cloudProvider == "AWS" {

	} else if cloudProvider == "GCP" {

	} else {
		checkStringErrorAzure(err)
	}
}

func checkStringErrorAzure(err string) {
	client := appinsights.NewTelemetryClient(os.Getenv("APPINSIGHTS_INSTRUMENTATIONKEY"))
	trace := appinsights.NewTraceTelemetry(err, appinsights.Error)
	trace.Timestamp = time.Now()
	client.Track(trace)
	defer appinsights.TrackPanic(client, false)
	panic(err)
}

func checkError(err error) {
	cloudProvider := os.Getenv("CLOUD_PROVIDER")
	if cloudProvider == "AWS" {

	} else if cloudProvider == "GCP" {

	} else {
		checkErrorAzure(err)
	}
}

func checkErrorAzure(err error) {
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
