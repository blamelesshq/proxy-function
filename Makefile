docker_name=lambda
init: build run

build:
	docker build -t $(docker_name):v1 .

run:
	docker run --name $(docker_name) $(docker_name):v1

zip-aws:
	# remove container if it exists. Ignore error when container not exist
	docker rm $(docker_name) || true 
	$(MAKE) init
	docker cp $(docker_name):/go/src/github.com/blamelesshq/lambda-prometheus/function.zip ./function.zip
	docker rm $(docker_name)

zip-gcp:
	zip -j function_gcp.zip fetch/* go.mod go.sum

deploy_aws: zip-aws
	cd ./deploy/aws; terraform apply

deploy_gcp: zip-gcp
	cd ./deploy/gcp; terraform apply

.PHONY: deploy
deploy:
	@read -p "Chose cloud to deploy a prometheus fetch function (AWS/GCP):" cloud; \
	if [ $$cloud = "AWS" ]; then $(MAKE) deploy_aws; fi; \
	if [ $$cloud = "GCP" ]; then $(MAKE) deploy_gcp; fi;
