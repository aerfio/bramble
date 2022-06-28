FROM golang:alpine

WORKDIR /go/src/app

COPY . .
RUN go get
CMD go run .
