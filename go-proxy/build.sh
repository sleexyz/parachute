#!/bin/sh

gomobile bind -v -target=ios \
    -o ../ci_scripts/Ffi.xcframework \
    strange.industries/go-proxy/pkg/ffi 
