package ffi

import (
	"encoding/json"
	"fmt"
	"log"
	"runtime"
	"runtime/debug"

	"github.com/getsentry/sentry-go"
	"google.golang.org/protobuf/proto"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
	"strange.industries/go-proxy/pkg/controller"
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
	defer sentry.Recover()
	r := &proxyservice.Settings{}
	err := proto.Unmarshal(settingsData, r)
	if err != nil {
		log.Panicf("could not start server: %s", err)
	}
	p.Proxy.Start(port, r)
}

func (p *OnDeviceProxyBridge) Rpc(input []byte) ([]byte, error) {
	defer sentry.Recover()
	r := &proxyservice.Request{}
	err := proto.Unmarshal(input, r)
	if err != nil {
		return nil, err
	}
	log.Printf("/Rpc %s", r)
	switch r.Message.(type) {
	case *proxyservice.Request_SetSettings:
		m := r.GetSetSettings()
		p.Proxy.SetSettings(m)
	case *proxyservice.Request_ResetState:
		p.Proxy.ResetState()
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

func InitDebug(env string, debugServerAddr string) ProxyBridge {
	log.SetOutput(MobileLogger{})
	InitSentry(env)
	defer sentry.Recover()
	return proxy.InitDebugClientProxyBridge(debugServerAddr)
}

func Init(env string) ProxyBridge {
	// log.SetOutput(io.Discard)
	log.SetOutput(MobileLogger{})
	InitSentry(env)
	defer sentry.Recover()
	a := &analytics.NoOpAnalytics{}
	c := controller.Init(a, controller.ProdAppConfigs)
	return &OnDeviceProxyBridge{
		Proxy: proxy.InitOnDeviceProxy(a, c),
	}
}

func InitSentry(env string) {
	err := sentry.Init(sentry.ClientOptions{
		Environment:      env,
		AttachStacktrace: true,
		Dsn:              "https://30011f92c5f545dbb68d373ddd1179ed@o4504415494602752.ingest.sentry.io/4504415507709952",
		// Set TracesSampleRate to 1.0 to capture 100%
		// of transactions for performance monitoring.
		// We recommend adjusting this value in production,
		TracesSampleRate: 1.0,
	})
	if err != nil {
		log.Fatalf("sentry.Init: %s", err)
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
