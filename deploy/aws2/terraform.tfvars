lambda_env = {
RouteConfig = "test"
CLOUD_ENVIRONMENT = "AWS"
}
lambda_handler = "lambda"
lambda_runtime = "go1.x"
lambda_package = "../../ProxyFunction/function.zip"
lambda_name = "prometheus_lambda_23"
project = "prometheus_lambda"
stage_name = "production"
region = "us-west-1"
lambda_timeout = 50
