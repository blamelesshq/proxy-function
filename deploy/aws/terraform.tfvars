lambda_env = {
    RouteConfig = "test"
    CLOUD_ENVIRONMENT = "AWS"
}
lambda_handler = "lambda"
lambda_runtime = "go1.x"
lambda_package = "./function_aws.zip"
lambda_name = "proxy-function"
project = "proxy-function"
stage_name = "production"
region = "us-west-1"
lambda_timeout = 50
