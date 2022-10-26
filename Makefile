BINARY = digitalocean_exporter
GOARCH = amd64

IMAGE 		?=ghcr.io/containerinfra/digitalocean-exporter
VERSION		?=local
COMMIT		?=$(shell git rev-parse HEAD)
BUILD_DATE	?=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_BY 	?=make

LDFLAGS = -X main.version=${VERSION} -X main.commit=${COMMIT} -X main.date=${BUILD_DATE} -X main.builtBy="${BUILD_BY}"

compile: build

linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=${GOARCH} go build  -ldflags "${LDFLAGS}" -o ./bin/${BINARY}_linux_${GOARCH}/${BINARY} . ;

darwin:
	CGO_ENABLED=0 GOOS=darwin GOARCH=${GOARCH} go build -ldflags "${LDFLAGS}" -o ./bin/${BINARY}_darwin_${GOARCH}/${BINARY} . ;

build:
	CGO_ENABLED=0 go build -ldflags "${LDFLAGS}" -o ./bin/${BINARY} . ;

test:
	go test -v ./... -cover

fmt:
	go fmt $$(go list ./... | grep -v /vendor/);

lint:
	golint $$(go list ./... | grep -v /vendor/)

vet:
	go vet $$(go list ./... | grep -v /vendor/) ;


docker: linux
	docker build -t ${IMAGE}:${VERSION}${BRANCH} .

review:
	reviewdog -diff="git diff FETCH_HEAD" -tee

goreleaser:
	goreleaser release --skip-publish --skip-announce --skip-validate --snapshot --skip-validate --rm-dist
