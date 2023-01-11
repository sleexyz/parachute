package ffi

import (
	"fmt"
	"log"
	"runtime"
	"runtime/debug"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
	"gvisor.dev/gvisor/pkg/bufferv2"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
	"strange.industries/go-proxy/pkg/controller"
	proxy "strange.industries/go-proxy/pkg/proxy"
)

type ProxyBridge interface {
	// Deprecate
	StartUDPServer(port int, settingsData []byte)
	StartDirectProxyConnection(cbs Callbacks, settingsData []byte)
	Close()
	// Data plane
	WriteOutboundPacket(b []byte)
	// Control plane
	Rpc(input []byte) ([]byte, error)
}

type OnDeviceProxyBridge struct {
	*proxy.Proxy
	*OutboundChannel
}

type Callbacks interface {
	WriteInboundPacket(b []byte)
}

type TunConnAdapter struct {
	cbs Callbacks
	oc  *OutboundChannel
}

func InitTunConnAdapter(cbs Callbacks, oc *OutboundChannel) *TunConnAdapter {
	return &TunConnAdapter{cbs, oc}
}

func (t *TunConnAdapter) Write(b []byte) (int, error) {
	// tee.LogPacket("inbound", b)
	t.cbs.WriteInboundPacket(b)
	return len(b), nil
}

// Read outbound packets
func (t *TunConnAdapter) Read(b []byte) (int, error) {
	packet := t.oc.ReadOutboundPacket()
	// tee.LogPacket("outbound (read)", packet)
	i := copy(b, packet)
	return i, nil
}

func (t *TunConnAdapter) Close() {
}

func (p *OnDeviceProxyBridge) Close() {
	p.Proxy.Close()
}

type OutboundChannel struct {
	outbound chan *bufferv2.View
}

func InitOutboundChannel() *OutboundChannel {
	return &OutboundChannel{
		outbound: make(chan *bufferv2.View),
	}
}

func (p *OutboundChannel) WriteOutboundPacket(b []byte) {
	// tee.LogPacket("outbound (write)", b)
	v := bufferv2.NewViewSize(len(b))
	slice := v.AsSlice()
	copy(slice, b)
	p.outbound <- v
}

func (p *OutboundChannel) ReadOutboundPacket() []byte {
	result := <-p.outbound
	defer result.Release()
	return result.AsSlice()
}

func (p *OnDeviceProxyBridge) StartDirectProxyConnection(cbs Callbacks, settingsData []byte) {
	log.Printf("starting direct proxy connection")
	r := &proxyservice.Settings{}
	err := proto.Unmarshal(settingsData, r)
	if err != nil {
		log.Panicf("could not unmarshal settings on connection start : %s", err)
	}
	p.Proxy.Start(InitTunConnAdapter(cbs, p.OutboundChannel), r)
}

func (p *OnDeviceProxyBridge) StartUDPServer(port int, settingsData []byte) {
	r := &proxyservice.Settings{}
	err := proto.Unmarshal(settingsData, r)
	if err != nil {
		log.Panicf("could not start server: %s", err)
	}
	p.Proxy.StartUDPServer(port, r)
}

func (p *OnDeviceProxyBridge) Rpc(input []byte) ([]byte, error) {
	r := &proxyservice.Request{}
	err := proto.Unmarshal(input, r)
	if err != nil {
		return nil, err
	}
	// debugText, _ := debugMarshalOptions.Marshal(r)
	// log.Printf("/Rpc %s", debugText)

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
	case *proxyservice.Request_Heal:
		p.Proxy.Heal()
		resp.Message = &proxyservice.Response_Heal{
			Heal: &proxyservice.HealResponse{
				UsagePoints: p.Proxy.GetState().UsagePoints,
			},
		}
	default:
		return nil, fmt.Errorf("could not parse rpc command")
	}
	// debugText, _ = debugMarshalOptions.Marshal(resp)
	// log.Printf("/RpcResponse %s", debugText)
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

func InitDebug(env string, dataAddr string, controlAddr string) ProxyBridge {
	log.SetOutput(MobileLogger{})
	return InitDebugClientProxyBridge(dataAddr, controlAddr)
}

func Init(env string) ProxyBridge {
	// log.SetOutput(io.Discard)
	log.SetOutput(MobileLogger{})
	a := &analytics.NoOpAnalytics{}
	sm := controller.InitSettingsManager()
	c := controller.Init(a, sm, controller.ProdAppConfigs)
	return &OnDeviceProxyBridge{
		OutboundChannel: InitOutboundChannel(),
		Proxy:           proxy.InitOnDeviceProxy(a, c),
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
