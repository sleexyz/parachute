all: ../ci_scripts/Ffi.xcframework

compilers: .external/swift-protobuf/.build/release/protoc-gen-swift .analysis-sandbox/node_modules/.bin/protoc-gen-ts_proto

.analysis-sandbox/node_modules/.bin/protoc-gen-ts_proto:
	(cd analysis-sandbox; npm install)

.external/swift-protobuf/.build/release/protoc-gen-swift:
	mkdir -p .external
	git clone https://github.com/apple/swift-protobuf.git .external/swift-protobuf
	(cd .external/swift-protobuf; git checkout tags/1.20.3)
	(cd .external/swift-protobuf; swift build -c release)	

../ci_scripts/Ffi.xcframework: $(shell git ls-files | grep .go$) 
	# Changed files
	echo $?
	./build.sh

pkg/controller/mock_DeviceCallbacks.go:
	mockery --name=DeviceCallbacks  --recursive --inpackage --dir pkg/controller

test: pkg/controller/mock_DeviceCallbacks.go
	go test ./...

.PHONY = clean test
clean: 
	rm -f pb/proxyservice/proxyservice.pb.go
	rm -rf ../ci_scripts/Ffi.xcframework
	rm -f pkg/controller/mock_DeviceCallbacks.go

analysis-sandbox/src/proxyservice.ts pb/proxyservice/proxyservice.pb.go ProxyService/Sources/ProxyService/proxyservice.pb.swift: protos/proxyservice.proto
	./build_protos.sh

