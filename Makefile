exec=lambda-prometheus
init: build run

build:
	go get ./...
	go build -o $(exec) .
run:
	 ./$(exec)
zip-aws:
	GOOS=linux go build -o $(exec) .
	zip function.zip $(exec)
