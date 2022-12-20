#!/bin/sh

# if protoc -I=protos --go_out=. protos/proxyservice.proto; then
protoc -I=protos \
  --go_out=. \
  --plugin=./.external/swift-protobuf/.build/release/protoc-gen-swift \
  --swift_out=ProxyService/Sources/ProxyService --swift_opt=Visibility=Public \
  --plugin=./analysis-sandbox/node_modules/.bin/protoc-gen-ts_proto \
  --ts_proto_out=./analysis-sandbox/src/ \
  protos/proxyservice.proto && echo "successfully generated protos"
