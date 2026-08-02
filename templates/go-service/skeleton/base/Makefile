.PHONY: build test run vet

build:
	go build -o bin/server ./cmd/server

test:
	go test -race ./...

vet:
	go vet ./...

run:
	go run ./cmd/server
