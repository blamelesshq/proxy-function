provider "aws" {
  profile    = "default"
  region = "us-west-1"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.iam_for_lambda_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_api_gateway_rest_api" "api_gateway_for_lambda" {
  name = "${var.aws_api_gateway_rest_api}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api_resource_for_api_gateway" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_for_lambda.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_for_lambda.root_resource_id}"
  path_part = "{proxy+}"
}

resource "aws_api_gateway_method" "api_method_for_api_resource" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_for_lambda.id}"
  resource_id   = "${aws_api_gateway_resource.api_resource_for_api_gateway.id}"
  http_method   = "ANY"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api_gateway_for_lambda.id}"
  resource_id             = "${aws_api_gateway_resource.api_resource_for_api_gateway.id}"
  http_method             = "${aws_api_gateway_method.api_method_for_api_resource.http_method}"
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.prometheus_lambda.invoke_arn}"
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.prometheus_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api_gateway_for_lambda.id}/*/${aws_api_gateway_method.api_method_for_api_resource.http_method}${aws_api_gateway_resource.api_resource_for_api_gateway.path}"
}

resource "aws_lambda_function" "prometheus_lambda" {
  filename      = "${var.code_dir}"
  function_name = "${var.lambda_function_name}"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "lambda"
  source_code_hash = "${filebase64sha256("${var.code_dir}")}"
  runtime = "go1.x"
  depends_on = ["aws_iam_role_policy_attachment.lambda_logs", "aws_cloudwatch_log_group.lambda_log_group"]#, "aws_iam_role_policy_attachment.lambda_dkms"]
  # kms_key_arn = "${aws_kms_key.main.arn}"

  environment {
    variables = {
      RouteConfig = "${var.route_config}"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "${var.aws_cloudwatch_log_group_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.lambda_logging_name}"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# resource "aws_iam_policy" "lambda_kms" {
#   name = "${var.aws_iam_policy_name}"
#   path = "/"
#   description = "IAM policy for decrypt env for a lambda"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": {
#     "Effect": "Allow",
#     "Action": [
#       "kms:DescribeKey",
#       "kms:GenerateDataKey",
#       "kms:Decrypt"
#     ],
#     "Resource": [
#       "${aws_kms_key.main.arn}"
#     ]
#   }
# }
# EOF
# }


resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

# resource "aws_iam_role_policy_attachment" "lambda_dkms" {
#   role       = "${aws_iam_role.iam_for_lambda.name}"
#   policy_arn = "${aws_iam_policy.lambda_kms.arn}"
# }


resource "aws_api_gateway_deployment" "deploy_api_gateway" {
  depends_on = ["aws_api_gateway_integration.integration"]
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_for_lambda.id}"
  stage_name = "${var.api_gateway_deploy_name}"
}

resource "aws_api_gateway_api_key" "aws_api_key_for_lambda_api" {
  name="${var.aws_api_gateway_api_key}"
}

resource "aws_api_gateway_usage_plan" "aws_prometheus_lambda_plan" {
  name="${var.aws_api_gateway_usage_plan}"

  api_stages {
    api_id = "${aws_api_gateway_rest_api.api_gateway_for_lambda.id}"
    stage = "${aws_api_gateway_deployment.deploy_api_gateway.stage_name}"
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = "${aws_api_gateway_api_key.aws_api_key_for_lambda_api.id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.aws_prometheus_lambda_plan.id}"
}

# resource "aws_kms_key" "main" {
#   description = "key for encrypt lambda Prometheus variables"
#  is_enabled = true
##   deletion_window_in_days = 7
# }

# resource "aws_kms_ciphertext" "prometheus_login" {
#   key_id = "${aws_kms_key.main.key_id}"
#   plaintext = "${var.prometheus_login}"
# }

# resource "aws_kms_ciphertext" "prometheus_password" {
#   key_id = "${aws_kms_key.main.key_id}"
#   plaintext = "${var.prometheus_password}"
# }
