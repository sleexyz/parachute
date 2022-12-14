package proxy

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"strange.industries/go-proxy/pkg/analytics"
	"strange.industries/go-proxy/pkg/controller"
	"strange.industries/go-proxy/pkg/logger"
)

type DebugClientProxy struct {
	debugServerAddr string
}

func InitDebugClientProxy(debugServerAddr string) *DebugClientProxy {
	return &DebugClientProxy{debugServerAddr: debugServerAddr}
}

func (p *DebugClientProxy) Start(port int) {
}

func (p *DebugClientProxy) Close() {
}

func (p *DebugClientProxy) CallCommand(command string, input []byte) ([]byte, error) {
	url := fmt.Sprintf("http://%s/Command/%s", p.debugServerAddr, command)
	logger.Logger.Printf("POST %s", url)
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(input))
	if err != nil {
		return nil, err
	}
	return io.ReadAll(resp.Body)
}

func (p *DebugClientProxy) GetSpeed() *controller.GetSpeedResponse {
	logger.Logger.Printf("/GetSpeed")
	in, err := json.Marshal(struct{}{})
	if err != nil {
		logger.Logger.Fatalln("Could not marshal request")
	}
	out, err := p.CallCommand("GetSpeed", in)
	var resp *controller.GetSpeedResponse
	json.Unmarshal(out, &resp)
	if err != nil {
		logger.Logger.Fatalln("Could not unmarshal response")
	}
	return resp
}

func (p *DebugClientProxy) GetRecentFlows() []analytics.Flow {
	logger.Logger.Printf("/GetRecentFlows")
	in, err := json.Marshal(struct{}{})
	if err != nil {
		logger.Logger.Fatalln("Could not marshal request")
	}
	out, err := p.CallCommand("GetRecentFlows", in)
	var resp []analytics.Flow
	json.Unmarshal(out, &resp)
	if err != nil {
		logger.Logger.Fatalln("Could not unmarshal response")
	}
	return resp
}

func (p *DebugClientProxy) Pause() {
	req, err := json.Marshal(struct{}{})
	if err != nil {
		logger.Logger.Fatalln("Could not marshal request")
	}
	_, err = p.CallCommand("Pause", req)
	if err != nil {
		logger.Logger.Fatalln("Could not unmarshal response")
	}
	return
}
