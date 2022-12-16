package ffi

import (
	"encoding/json"
	"fmt"
	"log"
	"runtime"
	"runtime/debug"

	proxy "strange.industries/go-proxy/pkg/proxy"
)

type ProxyBridge interface {
	Command(command string, input []byte) ([]byte, error)
}

type OnDeviceProxyBridge struct {
	Proxy proxy.Proxy
}

type SetTemporaryRxSpeedTargetRequest struct {
	Target   float64 `json:"target"`
	Duration int     `json:"duration"`
}

func (p *OnDeviceProxyBridge) Command(command string, input []byte) ([]byte, error) {
	switch command {
	case "Start":
		var port int
		json.Unmarshal(input, &port)
		p.Proxy.Start(port)
	case "Close":
		p.Proxy.Close()
	case "GetSpeed":
		return p.encodeResponse(p.Proxy.GetSpeed()), nil
	case "SetRxSpeedTarget":
		var req float64
		json.Unmarshal(input, &req)
		p.Proxy.SetRxSpeedTarget(req)
	case "SetTemporaryRxSpeedTarget":
		var req SetTemporaryRxSpeedTargetRequest
		json.Unmarshal(input, &req)
		p.Proxy.SetTemporaryRxSpeedTarget(req.Target, req.Duration)
	default:
		return nil, fmt.Errorf("unexpected command %s", command)
	}
	return p.encodeResponse(struct{}{}), nil
}

func (p *OnDeviceProxyBridge) encodeResponse(resp any) []byte {
	out, err := json.MarshalIndent(resp, "", "  ")
	if err != nil {
		log.Fatalf("Error: %s", err)
		return make([]byte, 0)
	}
	return out
}

func InitDebug(debugServerAddr string) ProxyBridge {
	log.SetOutput(MobileLogger{})
	return proxy.InitDebugClientProxyBridge(debugServerAddr)

}

func Init() ProxyBridge {
	// log.SetOutput(io.Discard)
	log.SetOutput(MobileLogger{})
	return &OnDeviceProxyBridge{
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
