package ffi

import (
	"runtime"
	"runtime/debug"

	proxy "strange.industries/go-proxy/pkg/proxy"
)

var p *proxy.ServerProxy

func MaxProcs(max int) int {
	return runtime.GOMAXPROCS(max)
}

func SetMemoryLimit(limit int64) int64 {
	return debug.SetMemoryLimit(limit)
}

func SetGCPercent(pct int) int {
	return debug.SetGCPercent(pct)
}

func Start(port int) {
	p = &proxy.ServerProxy{}
	p.Start(port)
}

func Close() {
	p.Close()
}
