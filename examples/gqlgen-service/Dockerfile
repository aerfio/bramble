FROM golang:alpine

WORKDIR /go/src/app

COPY . .

ENV CGO_ENABLED=0

RUN go generate .
RUN go get
CMD go run .
