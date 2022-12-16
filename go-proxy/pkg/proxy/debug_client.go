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

func (p *DebugClientProxyBridge) Command(command string, input []byte) ([]byte, error) {
	url := fmt.Sprintf("http://%s/Command/%s", p.debugServerAddr, command)
	log.Printf("POST %s", url)
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(input))
	if err != nil {
		return nil, err
	}
	return io.ReadAll(resp.Body)
}
