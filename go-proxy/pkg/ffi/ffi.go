package ffi

import (
	"log"
	"runtime"
	"runtime/debug"

	proxy "strange.industries/go-proxy/pkg/proxy"
)

type Proxy interface {
	Start(port int)
	Close()
	GetRecentFlows() []byte
	SetLatency(ms int)
}

func InitDebug(debugServerAddr string) Proxy {
	mobilelog := MobileLogger{}
	logger := log.New(mobilelog, "", 0)

	return &proxy.DebugClientProxy{
		DebugServerAddr: debugServerAddr,
		Log:             logger,
	}
}

func Init() Proxy {
	return &proxy.ServerProxy{}
}

func MaxProcs(max int) int {
	return runtime.GOMAXPROCS(max)
}

func SetMemoryLimit(limit int64) int64 {
	return debug.SetMemoryLimit(limit)
}

func SetGCPercent(pct int) int {
	return debug.SetGCPercent(pct)
}
