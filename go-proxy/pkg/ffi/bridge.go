package ffi

import (
	"log"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
	"strange.industries/go-proxy/pb/proxyservice"
	proxy "strange.industries/go-proxy/pkg/proxy"
)

type Callbacks interface {
	WriteInboundPacket(b []byte)
}

type ProxyBridge interface {
	// Deprecate
	StartUDPServer(port int, settingsData []byte)
	StartDirectProxyConnection(cbs Callbacks, settingsData []byte)
	Close()
	// Data plane
	WriteOutboundPacket(b []byte)
	// Control plane
	Rpc(input []byte) []byte
}

type OnDeviceProxyBridge struct {
	*proxy.Proxy
	*OutboundChannel
}

func (p *OnDeviceProxyBridge) Close() {
	p.Proxy.Close()
}

func (p *OnDeviceProxyBridge) StartDirectProxyConnection(cbs Callbacks, settingsData []byte) {
	log.Printf("starting direct proxy connection")
	s := &proxyservice.Settings{}
	err := proto.Unmarshal(settingsData, s)
	if err != nil {
		log.Panicf("could not unmarshal settings on connection start : %s", err)
	}
	p.Proxy.Start(InitTunConnAdapter(cbs, p.OutboundChannel), s)
}

func (p *OnDeviceProxyBridge) StartUDPServer(port int, settingsData []byte) {
	s := &proxyservice.Settings{}
	err := proto.Unmarshal(settingsData, s)
	if err != nil {
		log.Panicf("could not start server: %s", err)
	}
	p.Proxy.StartUDPServer(port, s)
}

func (p *OnDeviceProxyBridge) Rpc(input []byte) []byte {
	r := &proxyservice.Request{}
	err := proto.Unmarshal(input, r)
	if err != nil {
		return nil
	}
	// debugText, _ := prototext.Marshal(r)
	// log.Printf("/Rpc request %s", debugText)

	switch r.Message.(type) {
	case *proxyservice.Request_SetSettings:
		m := r.GetSetSettings()
		p.Proxy.SetSettings(m)
		return p.encodeResponse(&proxyservice.SetSettingsResponse{})
	case *proxyservice.Request_GetState:
		return p.encodeResponse(p.Proxy.GetState())
	case *proxyservice.Request_Heal:
		p.Proxy.Heal()
		return p.encodeResponse(&proxyservice.HealResponse{
			UsagePoints: p.Proxy.GetState().UsagePoints,
		})
	default:
		return nil
	}
}

func (p *OnDeviceProxyBridge) encodeResponse(resp protoreflect.ProtoMessage) []byte {
	// debugText, _ := prototext.Marshal(resp)
	// log.Printf("/Rpc response %s", debugText)
	out, err := proto.Marshal(resp)
	if err != nil {
		log.Fatalf("Error: %s", err)
		return nil
	}
	copied := make([]byte, len(out))
	copy(copied, out)
	return copied
}
