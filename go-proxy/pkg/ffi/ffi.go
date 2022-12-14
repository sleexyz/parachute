package ffi

import (
	"encoding/json"
	"log"
	"runtime"
	"runtime/debug"

	"strange.industries/go-proxy/pkg/logger"
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
		logger.Logger.Fatalf("Error: %s", err)
		return make([]byte, 0)
	}
	return out
}

func InitDebug(debugServerAddr string) ProxyBridge {
	logger.SetGlobalLogger(log.New(MobileLogger{}, "", 0))
	logger.Logger.Printf("Initialized Debug Proxy Client, connected to %s", debugServerAddr)

	return &LocalProxyBridge{
		Proxy: proxy.InitDebugClientProxy(debugServerAddr),
	}
}

func Init() ProxyBridge {
	logger.SetGlobalLogger(log.New(MobileLogger{}, "", 0))
	logger.Logger.Printf("Initialized Local Proxy Server")
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
