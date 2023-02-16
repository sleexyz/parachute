all: ci_scripts/Ffi.xcframework

everything: ci_scripts/pull_bin ci_scripts/push_bin all

compilers := $(proto-compilers) .gopath/bin/gomobile

proto-compilers := .external/swift-protobuf/.build/release/protoc-gen-swift go-proxy/analysis-sandbox/node_modules/.bin/protoc-gen-ts_proto .gopath/bin/protoc-gen-go

.gopath/bin/gomobile:
	go install golang.org/x/mobile/cmd/gomobile@v0.0.0-20221110043201-43a038452099
	gomobile init

.gopath/bin/protoc-gen-go:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28.1

ci_scripts/pull_bin: ci_scripts/pull/main.go
	GOOS=darwin GOARCH=amd64 go build -o ./ci_scripts/pull_bin ./ci_scripts/pull/main.go

ci_scripts/push_bin: ci_scripts/push/main.go
	GOOS=darwin GOARCH=amd64 go build -o ./ci_scripts/push_bin ./ci_scripts/push/main.go

go-files := $(shell git ls-files | grep ^go-proxy/.*\.go$ ) 

go-proxy/analysis-sandbox/node_modules/.bin/protoc-gen-ts_proto:
	(cd analysis-sandbox; npm install)

.external/swift-protobuf/.build/release/protoc-gen-swift:
	mkdir -p .external
	git clone https://github.com/apple/swift-protobuf.git .external/swift-protobuf
	(cd .external/swift-protobuf; git checkout tags/1.20.3)
	(cd .external/swift-protobuf; swift build -c release)	

ci_scripts/Ffi.xcframework: $(go-files) $(compilers)
	echo $?
	(cd go-proxy ; ./build.sh)

go-proxy/pkg/controller/mock_DeviceCallbacks.go:
	mockery --name=DeviceCallbacks  --recursive --inpackage --dir go-proxy/pkg/controller

test-tools := .gopath/bin/mockery

.gopath/bin/mockery:
	go install github.com/vektra/mockery/v2@v2.16.0

test: $(test-tools) go-proxy/pkg/controller/mock_DeviceCallbacks.go
	go test ./go-proxy/...


.PHONY = all everything clean test clean-tools clean-test-tools clean-all
clean: 
	rm -f go-proxy/pb/proxyservice/proxyservice.pb.go
	rm -rf ci_scripts/Ffi.xcframework
	rm -f go-proxy/pkg/controller/mock_DeviceCallbacks.go

clean-tools: 
	rm -f .gopath/bin/gomobile
	rm -f .gopath/bin/protoc-gen-go
	rm -f .gopath/bin/gomobile
	rm -f .gopath/bin/protoc-gen-go
	rm -rf .external/swift-protobuf

clean-test-tools:
	rm -f .gopath/bin/mockery


go-proxy/analysis-sandbox/src/proxyservice.ts go-proxy/pb/proxyservice/proxyservice.pb.go ProxyService/Sources/ProxyService/proxyservice.pb.swift: protos/proxyservice.proto $(proto-compilers)
	./build_protos.sh
