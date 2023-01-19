//go:build tools
// +build tools

package main

import (
	_ "golang.org/x/mobile/cmd/gomobile"
	_ "google.golang.org/protobuf/cmd/protoc-gen-go"
)
