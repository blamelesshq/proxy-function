docker_name=lambda
init: build run

build:
	docker build -t $(docker_name):v1 .

run:
	docker run --name $(docker_name) $(docker_name):v1

zip-aws: init
	docker cp $(docker_name):/go/src/github.com/blamelesshq/lambda-prometheus/function.zip ./function.zip
	docker rm $(docker_name)

deploy: zip-aws
	terraform apply
