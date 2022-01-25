lambda_env = {
RouteConfig = "test"
}
lambda_handler = "lambda"
lambda_runtime = "go1.x"
lambda_package = "../../ProxyFunctionAws/function.zip"
lambda_name = "prometheus_lambda_22"
project = "prometheus_lambda"
stage_name = "production"
region = "us-west-1"
lambda_timeout = 50
