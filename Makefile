.PHONY = all
all: protos

.PHONY = everything
everything: ci_scripts/push_bin all

ci_scripts/push_bin: ci_scripts/push/main.go
	GOOS=darwin GOARCH=amd64 go build -o ./ci_scripts/push_bin ./ci_scripts/push/main.go

.PHONY = clean
clean:
	rm -rf $(protos)

.PHONY = clean-tools
clean-tools: 
	rm -rf .external/swift-protobuf

protos := ProxyService/Sources/ProxyService/proxyservice.pb.swift

.PHONY = protos
protos: $(protos)

$(protos): protos/proxyservice.proto .external/swift-protobuf/.build/release/protoc-gen-swift
	./build_protos.sh

.external/swift-protobuf/.build/release/protoc-gen-swift:
	mkdir -p .external
	git clone https://github.com/apple/swift-protobuf.git .external/swift-protobuf
	(cd .external/swift-protobuf; git checkout tags/1.20.3)
	(cd .external/swift-protobuf; swift build -c release)	