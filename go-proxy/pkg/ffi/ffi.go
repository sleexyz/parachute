package ffi

import (
	"fmt"
	"log"
	"runtime"
	"runtime/debug"

	"github.com/getsentry/sentry-go"
	"google.golang.org/protobuf/encoding/prototext"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
	"strange.industries/go-proxy/pkg/controller"
	proxy "strange.industries/go-proxy/pkg/proxy"
)

var debugMarshalOptions = &prototext.MarshalOptions{
	Multiline: true,
	Indent:    "  ",
}

type ProxyBridge interface {
	StartProxy(port int, settingsData []byte)
	Close()
	Rpc(input []byte) ([]byte, error)
}

type OnDeviceProxyBridge struct {
	*proxy.Proxy
}

func (p *OnDeviceProxyBridge) Close() {
	p.Proxy.Close()

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
	debugText, _ := debugMarshalOptions.Marshal(r)
	log.Printf("/Rpc %s", debugText)

	resp := &proxyservice.Response{}
	switch r.Message.(type) {
	case *proxyservice.Request_SetSettings:
		m := r.GetSetSettings()
		p.Proxy.SetSettings(m)
		resp.Message = &proxyservice.Response_SetSettings{
			SetSettings: &proxyservice.SetSettingsResponse{},
		}
	case *proxyservice.Request_GetState:
		resp.Message = &proxyservice.Response_GetState{
			GetState: p.Proxy.GetState(),
		}
	default:
		return nil, fmt.Errorf("could not parse rpc command")
	}
	debugText, _ = debugMarshalOptions.Marshal(resp)
	log.Printf("/RpcResponse %s", debugText)
	return p.encodeResponse(resp), nil
	// return nil, nil
}

func (p *OnDeviceProxyBridge) encodeResponse(resp protoreflect.ProtoMessage) []byte {
	out, err := proto.Marshal(resp)
	if err != nil {
		log.Fatalf("Error: %s", err)
		return nil
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
	sm := controller.InitSettingsManager()
	c := controller.Init(a, sm, controller.ProdAppConfigs)
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
