all: Ffi.xcframework

compilers: .external/swift-protobuf/.build/release/protoc-gen-swift .analysis-sandbox/node_modules/.bin/protoc-gen-ts_proto

.analysis-sandbox/node_modules/.bin/protoc-gen-ts_proto:
	(cd analysis-sandbox; npm install)

.external/swift-protobuf/.build/release/protoc-gen-swift:
	mkdir -p .external
	git clone https://github.com/apple/swift-protobuf.git .external/swift-protobuf
	(cd .external/swift-protobuf; git checkout tags/1.20.3)
	(cd .external/swift-protobuf; swift build -c release)	


Ffi.xcframework: $(shell git ls-files | grep .go$) 
	# Changed files
	echo $?
	./build.sh

.PHONY = clean
clean: 
	rm pb/proxyservice/proxyservice.pb.go
	rm -rf Ffi.xcframework

analysis-sandbox/src/proxyservice.ts pb/proxyservice/proxyservice.pb.go ProxyService/Sources/ProxyService/proxyservice.pb.swift: protos/proxyservice.proto
	./build_protos.sh

