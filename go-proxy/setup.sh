#!/bin/sh

mkdir -p .external

git clone https://github.com/apple/swift-protobuf.git .external/swift-protobuf
cd .external/swift-protobuf
git checkout tags/1.20.3
swift build -c release
