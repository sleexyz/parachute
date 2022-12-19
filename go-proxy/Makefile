all: Ffi.xcframework

Ffi.xcframework: $(shell git ls-files | grep .go$) 
	# Changed files
	echo $?
	./build.sh

.PHONY = clean
clean: 
	rm pb/proxyservice/proxyservice.pb.go
	rm -rf Ffi.xcframework

pb/proxyservice/proxyservice.pb.go ProxyService/Sources/ProxyService/proxyservice.pb.swift: protos/proxyservice.proto
	./build_protos.sh

