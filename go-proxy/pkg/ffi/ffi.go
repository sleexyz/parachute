package ffi

import (
	"encoding/json"
	"fmt"
	"log"
	"runtime"
	"runtime/debug"

	"google.golang.org/protobuf/proto"
	"strange.industries/go-proxy/pb/proxyservice"
	proxy "strange.industries/go-proxy/pkg/proxy"
)

type ProxyBridge interface {
	StartProxy(port int, settingsData []byte)
	Close()
	Rpc(input []byte) ([]byte, error)
}

type OnDeviceProxyBridge struct {
	proxy.Proxy
}

func (p *OnDeviceProxyBridge) StartProxy(port int, settingsData []byte) {
	r := &proxyservice.Settings{}
	err := proto.Unmarshal(settingsData, r)
	if err != nil {
		log.Panicf("could not start server: %s", err)
	}
	p.Proxy.Start(port, r)
}

func (p *OnDeviceProxyBridge) Rpc(input []byte) ([]byte, error) {
	r := &proxyservice.Request{}
	err := proto.Unmarshal(input, r)
	if err != nil {
		return nil, err
	}
	log.Printf("/Rpc %s", r)
	switch r.Message.(type) {
	case *proxyservice.Request_SetTemporaryRxSpeedTarget:
		m := r.GetSetTemporaryRxSpeedTarget()
		p.Proxy.SetTemporaryRxSpeedTarget(m.Speed, int(m.Duration))
	case *proxyservice.Request_SetSettings:
		m := r.GetSetSettings()
		p.Proxy.SetSettings(m)
	default:
		return nil, fmt.Errorf("could not parse rpc command")
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
