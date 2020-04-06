FROM golang:1.13.9
WORKDIR /go/src/github.com/blamelesshq/lambda-prometheus
COPY Gopkg.lock .
COPY Gopkg.toml .
COPY vendor ./vendor
COPY Makefile .
COPY main.go .
COPY fetch.go .
RUN apt-get update && apt-get install zip -y
RUN GOOS=linux go build -o lambda ./...
CMD ["zip", "function.zip", "lambda"]
