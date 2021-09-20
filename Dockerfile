FROM golang:1.17rc2
WORKDIR /go/src/github.com/blamelesshq/lambda-prometheus
COPY go.mod .
COPY go.sum .
COPY main.go .
COPY ./fetch ./fetch
RUN apt-get update && apt-get install zip -y
RUN GOOS=linux go build -o lambda main.go
CMD ["zip", "function.zip", "lambda"]
