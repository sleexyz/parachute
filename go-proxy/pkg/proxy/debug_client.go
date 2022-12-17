package proxy

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"net/http"
)

type DebugClientProxyBridge struct {
	debugServerAddr string
}

func InitDebugClientProxyBridge(debugServerAddr string) *DebugClientProxyBridge {
	return &DebugClientProxyBridge{debugServerAddr: debugServerAddr}
}

func (p *DebugClientProxyBridge) Start(port int) {
	log.Printf("debug mode so nothing to start")
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
