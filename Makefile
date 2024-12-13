GOHOSTOS:=$(shell go env GOHOSTOS)
GOPATH:=$(shell go env GOPATH)
NAME=github.com/tlipoca9/tlipoca9-kratos-layout
VERSION=$(shell git describe --tags --always)

ifeq ($(GOHOSTOS), windows)
	#the `find.exe` is different from `find` in bash/shell.
	#to see https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/find.
	#changed to use git-bash.exe to run find cli or other cli friendly, caused of every developer has a Git.
	#Git_Bash= $(subst cmd\,bin\bash.exe,$(dir $(shell where git)))
	Git_Bash=$(subst \,/,$(subst cmd\,bin\bash.exe,$(dir $(shell where git))))
	INTERNAL_PROTO_FILES=$(shell $(Git_Bash) -c "find internal -name *.proto")
	API_PROTO_FILES=$(shell $(Git_Bash) -c "find api -name *.proto")
else
	INTERNAL_PROTO_FILES=$(shell find internal -name *.proto)
	API_PROTO_FILES=$(shell find api -name *.proto)
endif

.PHONY: init
# init env
init:
	@command -v go || (echo "please install 'go' manually, see doc: https://golang.org/doc/install" && exit 1)
	@command -v protoc || ((command -v brew && brew install protobuf) || (echo "please install 'protoc' manually, see doc: https://google.github.io/proto-lens/installing-protoc.html" && exit 1))
	command -v protoc-gen-go || go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	command -v protoc-gen-go-grpc || go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	command -v kratos || go install github.com/go-kratos/kratos/cmd/kratos/v2@latest
	command -v protoc-gen-go-http || go install github.com/go-kratos/kratos/cmd/protoc-gen-go-http/v2@latest
	command -v protoc-gen-openapi || go install github.com/google/gnostic/cmd/protoc-gen-openapi@latest
	command -v wire || go install github.com/google/wire/cmd/wire@latest
	command -v golangci-lint || (curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.61.0)

.PHONY: config
# generate internal proto
config:
	protoc --proto_path=./internal \
	       --proto_path=./third_party \
 	       --go_out=paths=source_relative:./internal \
	       $(INTERNAL_PROTO_FILES)

.PHONY: api
# generate api proto
api:
	protoc --proto_path=./api \
	       --proto_path=./third_party \
 	       --go_out=paths=source_relative:./api \
 	       --go-http_out=paths=source_relative:./api \
 	       --go-grpc_out=paths=source_relative:./api \
	       --openapi_out=fq_schema_naming=true,default_response=false:. \
	       $(API_PROTO_FILES)

.PHONY: dev
# dev
dev:
	kratos run -w .

.PHONY: build
# build
build:
	mkdir -p bin/
	go build -trimpath -ldflags="-s -w -extldflags=-static -X main.Name=$(NAME) -X main.Version=$(VERSION)" -o ./bin/ ./...

.PHONY: generate
# generate
generate:
	go generate ./...
	go mod tidy

.PHONY: lint
# golangci-lint
lint:
	golangci-lint run --fix ./...

.PHONY: all
# generate all
all:
	make api;
	make config;
	make generate;
	make lint;

# show help
.PHONY: help
help:
	@echo ''
	@echo 'Usage:'
	@echo ' make [target]'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
	helpMessage = match(lastLine, /^# (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 2, RLENGTH); \
			printf "\033[36m%-22s\033[0m %s\n", helpCommand,helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help
