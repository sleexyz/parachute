package ffi

import (
	"encoding/json"
	"io"
	"log"
	"runtime"
	"runtime/debug"

	proxy "strange.industries/go-proxy/pkg/proxy"
)

type ProxyBridge interface {
	Command(command string, input []byte) []byte
}

type LocalProxyBridge struct {
	Proxy proxy.Proxy
}

func (p *LocalProxyBridge) Command(command string, input []byte) []byte {
	switch command {
	case "Start":
		var port int
		json.Unmarshal(input, &port)
		p.Proxy.Start(port)
	case "Close":
		p.Proxy.Close()
	case "GetSpeed":
		return p.encodeResponse(p.Proxy.GetSpeed())
	case "GetRecentFlows":
		return p.encodeResponse(p.Proxy.GetRecentFlows())
	case "Pause":
		p.Proxy.Pause()
	default:
		return p.encodeResponse(nil)
	}
	return p.encodeResponse(struct{}{})
}

func (p *LocalProxyBridge) encodeResponse(resp any) []byte {
	out, err := json.MarshalIndent(resp, "", "  ")
	if err != nil {
		log.Fatalf("Error: %s", err)
		return make([]byte, 0)
	}
	return out
}

func InitDebug(debugServerAddr string) ProxyBridge {
	log.SetOutput(MobileLogger{})
	return &LocalProxyBridge{
		Proxy: proxy.InitDebugClientProxy(debugServerAddr),
	}
}

func Init() ProxyBridge {
	log.SetOutput(io.Discard)
	return &LocalProxyBridge{
		Proxy: proxy.InitServerProxy(),
	}
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
