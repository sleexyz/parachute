package ffi

import (
	"encoding/json"
	"runtime"
	"runtime/debug"

	proxy "strange.industries/go-proxy/pkg/proxy"
)

var p *proxy.ServerProxy

// Memory tuning functions

func MaxProcs(max int) int {
	return runtime.GOMAXPROCS(max)
}

func SetMemoryLimit(limit int64) int64 {
	return debug.SetMemoryLimit(limit)
}

func SetGCPercent(pct int) int {
	return debug.SetGCPercent(pct)
}

// Lifecycle functions

func Start(port int) {
	p = &proxy.ServerProxy{}
	p.Start(port)
}

func Close() {
	p.Close()
}

// Other functions

// Returns JSON encoded string
func GetRecentFlows() []byte {
	flows := p.C.Analytics.GetRecentFlows()
	out, err := json.MarshalIndent(flows, "", "  ")
	if err != nil {
		return nil
	}
	return out
}
