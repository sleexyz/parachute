#!/bin/sh

protoc -I=protos \
  --plugin=./.external/swift-protobuf/.build/release/protoc-gen-swift \
  --swift_out=./ProxyService/Sources/ProxyService --swift_opt=Visibility=Public \
  protos/proxyservice.proto && echo "successfully generated protos"
