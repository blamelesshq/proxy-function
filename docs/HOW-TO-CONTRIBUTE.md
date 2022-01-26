# Blameless Proxy function - How to Contribute and support multiple Cloud Providers

At the moment of this writting Proxy Function for Prometheus and Splunk support early access for AWS and GCP Cloud Providers.
In order to extend this and add GCP for example there is a need to write your own GCP Handler. 
For both AWS and Azure this is the sample [main Golang entryfile](../ProxyFunction/main.go):
```
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
```
In order to use Proxy Function integration there is a need for two environment varibles - RouteConfig and CLOUD_ENVIRONMENT to be defined. Please see samples for them in [template.yaml file](../ProxyFunction/template.yaml). 

After all the code is done and ready good practice is to create your own terraform script in the [deploy directory](../deploy) which will define your required infrastructure with all necessary environment variables defined in it.

> Note: For AWS and [Azure FuncCodeBuilder tool](../FuncCodeBuilder/ProxyFuncRouteUpdater) is used to build RouteConfig Environment variable from [route-config.yaml file](../ProxyFunction/route-config.yaml). It is prefered to build this environment variable from route-config.yaml file.

# Blameless Proxy function - How to Contribute and support other monitoring sources

In order to be able to support other monitoring sources apart from Prometheus and Splunk there is a need to write additional implementation for them either in [fetch.go](../ProxyFunction/fetch/fetch.go) or other file. 
This is the [handler example](../ProxyFunction/fetch/handler.go#L86) to distinquish the possible monitoring sources for now: 

```
resp, err := func() (*Response, error) {
		if fetch.Type == "Splunk" {
			return fetch.DoSplunk()
		} else {
			return fetch.DoAws()
		}
	}()
```
