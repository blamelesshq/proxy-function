.PHONY: setup-gcp
setup-gcp:
	cd ./deploy/gcp && \
	terraform init

.PHONY: gcp
gcp:
	cd ./src/gcp && \
	go mod vendor && \
	zip -r ../../deploy/gcp/function_gcp.zip ./*

	cd ./deploy/gcp && \
	terraform applyx

	rm ./deploy/gcp/function_gcp.zip
	
.PHONY: gcp-key
gcp-key:
	printf "api_key = %s\n\n" '$(shell cd ./deploy/gcp && terraform output --raw api_key)'

.PHONY: destroy-gcp
destroy-gcp:
	cd ./deploy/gcp && \
	terraform destroy

.PHONY: setup-aws
setup-aws:
	cd ./deploy/aws && \
	terraform init

.PHONY: aws
aws:
	cd ./src/aws && \
	go mod vendor && \
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ./proxy-function . && \
	zip -r ../../deploy/aws/function_aws.zip ./proxy-function && \
	rm ./proxy-function

	cd ./deploy/aws && \
	terraform apply

	rm ./deploy/aws/function_aws.zip
	
.PHONY: destroy-aws
destroy-aws:
	cd ./deploy/aws && \
	terraform destroy

.PHONY: setup-azure
setup-azure:
	cd ./deploy/azure && \
	terraform init

.PHONY: azure
azure:
	cd ./src/azure && \
	go mod vendor && \
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ./proxy-function/proxy-function . && \
	zip -r ../../deploy/azure/function_azure.zip ./proxy-function/* && \
	rm ./proxy-function/proxy-function

	cd ./deploy/azure && \
	terraform apply

	rm ./deploy/azure/function_azure.zip
	
.PHONY: destroy-azure
destroy-azure:
	cd ./deploy/azure && \
	terraform destroy