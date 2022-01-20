lambda_function_name = "prometheus_lambda_2"
aws_cloudwatch_log_group_name = "/aws/lambda/prometheus_3"
aws_api_gateway_rest_api = "api_for_prometheus_lambda_2"
aws_api_gateway_usage_plan = "prometheus_lambda_2_plan"
aws_api_gateway_api_key = "prometheus_lambda_key_2"
aws_iam_policy_name = "lambda_kms_decrypt_2"
route_config = "{\"Functions\":[{\"Route\":\"/api/fetch\",\"Url\":\"http://104.211.56.83:8089\",\"AccessToken\":\"eyJraWQiOiJzcGx1bmsuc2VjcmV0IiwiYWxnIjoiSFM1MTIiLCJ2ZXIiOiJ2MiIsInR0eXAiOiJzdGF0aWMifQ.eyJpc3MiOiJzcGx1bmsgZnJvbSBzcGx1bmsiLCJzdWIiOiJzcGx1bmsiLCJhdWQiOiJWZW5kb3IgdG9vbHMiLCJpZHAiOiJTcGx1bmsiLCJqdGkiOiJkMzliNzI3MzI3ZTVjMmNhOThkMmNmOTIwMDEwYzRmNzBiYTVmNjg4ZmZkNzFjZjY5OTgxMjg0M2FmYWM2YWYzIiwiaWF0IjoxNjMyOTY1NjU1LCJleHAiOjE2NTAyNDU2NTUsIm5iciI6MTYzMjk2NTY1NX0.2Z0V_NlqzbI0F33k3twyC_w9yxMmu0gh-zEaXs_qUddfqdMU5bFkmHYms2zLPAjeovNVINiBtmBkejF4zivXoQ\",\"Type\":\"Splunk\",\"Login\":null,\"Password\":null},{\"Route\":\"/api/fetch3\",\"Url\":\"http://104.211.56.83:8089\",\"AccessToken\":\"eyJraWQiOiJzcGx1bmsuc2VjcmV0IiwiYWxnIjoiSFM1MTIiLCJ2ZXIiOiJ2MiIsInR0eXAiOiJzdGF0aWMifQ.eyJpc3MiOiJzcGx1bmsgZnJvbSBzcGx1bmsiLCJzdWIiOiJzcGx1bmsiLCJhdWQiOiJWZW5kb3IgdG9vbHMiLCJpZHAiOiJTcGx1bmsiLCJqdGkiOiJkMzliNzI3MzI3ZTVjMmNhOThkMmNmOTIwMDEwYzRmNzBiYTVmNjg4ZmZkNzFjZjY5OTgxMjg0M2FmYWM2YWYzIiwiaWF0IjoxNjMyOTY1NjU1LCJleHAiOjE2NTAyNDU2NTUsIm5iciI6MTYzMjk2NTY1NX0.2Z0V_NlqzbI0F33k3twyC_w9yxMmu0gh-zEaXs_qUddfqdMU5bFkmHYms2zLPAjeovNVINiBtmBkejF4zivXoQ\",\"Type\":\"Splunk\",\"Login\":null,\"Password\":null},{\"Route\":\"/api/fetch4\",\"Url\":\"http://104.211.56.83:8089\",\"AccessToken\":\"eyJraWQiOiJzcGx1bmsuc2VjcmV0IiwiYWxnIjoiSFM1MTIiLCJ2ZXIiOiJ2MiIsInR0eXAiOiJzdGF0aWMifQ.eyJpc3MiOiJzcGx1bmsgZnJvbSBzcGx1bmsiLCJzdWIiOiJzcGx1bmsiLCJhdWQiOiJWZW5kb3IgdG9vbHMiLCJpZHAiOiJTcGx1bmsiLCJqdGkiOiJkMzliNzI3MzI3ZTVjMmNhOThkMmNmOTIwMDEwYzRmNzBiYTVmNjg4ZmZkNzFjZjY5OTgxMjg0M2FmYWM2YWYzIiwiaWF0IjoxNjMyOTY1NjU1LCJleHAiOjE2NTAyNDU2NTUsIm5iciI6MTYzMjk2NTY1NX0.2Z0V_NlqzbI0F33k3twyC_w9yxMmu0gh-zEaXs_qUddfqdMU5bFkmHYms2zLPAjeovNVINiBtmBkejF4zivXoQ\",\"Type\":\"Splunk\",\"Login\":null,\"Password\":null},{\"Route\":\"/api/prometheus-5\",\"Url\":\"http://prometheus23092021.westeurope.azurecontainer.io:9090/\",\"AccessToken\":null,\"Type\":\"Prometheus\",\"Login\":\"\",\"Password\":\"\"}]}"
code_dir = "../../ProxyFunctionAws/function.zip"
api_gateway_deploy_name = "blameless-prometheus-02"
iam_for_lambda_name = "iam_for_lambda_1"
lambda_logging_name = "lambda_logging_1"