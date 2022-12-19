package proxy

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"net/http"

	"google.golang.org/protobuf/proto"
	"strange.industries/go-proxy/pb/proxyservice"
)

type DebugClientProxyBridge struct {
	debugServerAddr string
}

func InitDebugClientProxyBridge(debugServerAddr string) *DebugClientProxyBridge {
	return &DebugClientProxyBridge{debugServerAddr: debugServerAddr}
}

func (p *DebugClientProxyBridge) StartProxy(port int, settingsData []byte) {
	// TODO: forward start data params to server
	log.Printf("debug mode so nothing to start")
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
	_, err = p.Rpc(input)
	if err != nil {
		log.Printf("could not forward proxy settings: %s", err)
		panic(1)
	}
}

func (p *DebugClientProxyBridge) Close() {
	log.Printf("debug mode so nothing to close")
}

func (p *DebugClientProxyBridge) Rpc(input []byte) ([]byte, error) {
	url := fmt.Sprintf("http://%s/Rpc", p.debugServerAddr)
	log.Printf("POST %s", url)
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(input))
	if err != nil {
		return nil, err
	}
	return io.ReadAll(resp.Body)
}
