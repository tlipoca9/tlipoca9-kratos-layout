# docker build -t github.com/tlipoca9/tlipoca9-kratos-layout .
# docker run -p 6060:6060 -p 8000:8000 -p 9000:9000 -v $(pwd)/configs:/data/conf github.com/tlipoca9/tlipoca9-kratos-layout
FROM golang:1.23-alpine3.20 AS builder
RUN apk update && apk upgrade
RUN apk add git make

RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN go env -w CGO_ENABLED=0

WORKDIR /src
COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . /src
RUN make build


FROM scratch

COPY --from=builder /src/bin /app
WORKDIR /app

EXPOSE 6060
EXPOSE 8000
EXPOSE 9000
VOLUME /data/conf

CMD ["./server", "-conf", "/data/conf"]
