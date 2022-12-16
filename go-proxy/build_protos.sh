#!/bin/sh

# if protoc -I=protos --go_out=. protos/proxyservice.proto; then
if protoc -I=protos --go_out=. --swift_out=ProxyService/Sources/ProxyService --swift_opt=Visibility=Public protos/proxyservice.proto; then
  echo "successfully generated protos"
fi
