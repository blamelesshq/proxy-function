module github.com/blamelesshq/proxy-function

go 1.16

replace github.com/blamelesshq/proxy-function/config => ../shared/config

replace github.com/blamelesshq/proxy-function/query => ../shared/query

require (
	github.com/GoogleCloudPlatform/functions-framework-go v1.5.3
	github.com/blamelesshq/proxy-function/config v0.0.0-00010101000000-000000000000 // indirect
	github.com/blamelesshq/proxy-function/query v0.0.0-00010101000000-000000000000
)
