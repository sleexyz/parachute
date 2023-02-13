package ffi

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"net/http"

	"google.golang.org/protobuf/proto"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/tee"
)

type DebugClientProxyBridge struct {
	*OutboundChannel
	dataAddr    string
	controlAddr string
	tee         *tee.Tee
}

func InitDebugClientProxyBridge(dataAddr string, controlAddr string) *DebugClientProxyBridge {
	return &DebugClientProxyBridge{
		OutboundChannel: InitOutboundChannel(),
		dataAddr:        dataAddr,
		controlAddr:     controlAddr,
	}
}

func (p *DebugClientProxyBridge) StartDirectProxyConnection(cbs Callbacks, settingsData []byte) {
	tee, err := tee.InitTee(InitTunConnAdapter(cbs, p.OutboundChannel), p.dataAddr)
	if err != nil {
		panic(err)
	}
	p.tee = tee

	go p.tee.Listen()
	p.forwardSettings(settingsData)
}

// deprecated.
func (p *DebugClientProxyBridge) StartUDPServer(port int, settingsData []byte) {
	// TODO: forward start data params to server
	log.Printf("debug mode so nothing to start")
	p.forwardSettings(settingsData)
}

func (p *DebugClientProxyBridge) forwardSettings(settingsData []byte) {
	s := &proxyservice.Settings{}
	err := proto.Unmarshal(settingsData, s)

	m := &proxyservice.Request{}
	m.Message = &proxyservice.Request_SetSettings{SetSettings: s}
	log.Printf("%s", m.String())

	if err != nil {
		log.Printf("could not forward proxy settings: %s", err)
		panic(1)
	}
	input, err := proto.Marshal(m)
	if err != nil {
		log.Printf("could not forward proxy settings: %s", err)
		panic(1)
	}
	_ = p.Rpc(input)
}

func (p *DebugClientProxyBridge) Close() {
	if p.tee != nil {
		p.tee.Close()
	}
}

func (p *DebugClientProxyBridge) Rpc(input []byte) []byte {
	url := fmt.Sprintf("http://%s/Rpc", p.controlAddr)
	log.Printf("POST %s", url)
	resp, err := http.Post(url, "application/octet-stream", bytes.NewBuffer(input))
	if err != nil {
		return nil
	}
	if resp.StatusCode != http.StatusOK {
		log.Printf("request failed with status code: %d", resp.StatusCode)
		return nil
	}
	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil
	}
	return data
}
