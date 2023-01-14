package ffi

import (
	"fmt"
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
	Rpc(input []byte) ([]byte, error)
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
