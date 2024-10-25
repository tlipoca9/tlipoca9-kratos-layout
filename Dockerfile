FROM golang:1.23-alpine3.20 AS builder
RUN apk update && apk upgrade
RUN apk add make

ENV GOPROXY https://goproxy.cn

WORKDIR /src
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . /src
RUN make build


FROM alpine:3.20

COPY --from=builder /src/bin /app
WORKDIR /app

EXPOSE 8000
EXPOSE 9000

CMD ["./server", "-conf", "/data/conf"]
