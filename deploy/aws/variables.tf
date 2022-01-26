# variable "prometheus_url" {
#   type = string
#   description = "URL to prometheus"
# }

# variable "prometheus_login" {
#   type = string
#   description = "Login for Prometheus"
# }

# variable "prometheus_password" {
#   type = string
#   description = "Password for Prometheus"
# }

variable "route_config" {
  type = string
  description = "Route Config"
}

variable "lambda_function_name" {
  type = string
  description = "Lambda Function Name"
  default = "prometheus_lambda_2"
}

variable "aws_cloudwatch_log_group_name" {
  type = string
  description = "Cloud Watch Log Group Name"
  default = "/aws/lambda/prometheus"
}

variable "aws_iam_policy_name" {
  type = string
  description = "IAM Policy name"
  default = "lambda_kms_decrypt"
} 

variable "aws_api_gateway_api_key" {
  type = string
  description = "Api Gateway API Key"
  default = "prometheus_lambda_key"
}

variable "aws_api_gateway_usage_plan" {
  type = string
  description = "Api Gateway Usage Plan"
  default = "prometheus_lambda_plan"
}

variable "aws_api_gateway_rest_api" {
  type = string
  description = "Api Gateway rest api"
  default = "api_for_prometheus_lambda"
}

variable "code_dir" {
  type = string
  description = "Code directory"
  default = "../../ProxyFunctionAws/function.zip"
}

variable "api_gateway_deploy_name" {
  type = string
  description = "Deployment name for API gateway"
}

variable "iam_role_name" {
  type = string
  description = "IAM role name"
  default = "IAM for lambda name"
}

variable "lambda_logging_name" {
  type = string
  description = "Lambda logging name"
  default = "lambda_logging"
}

variable "iam_for_lambda_name" {
  type = string
  description = "iam_for_lambda_name"
  default = "lambda_logging_1"
}