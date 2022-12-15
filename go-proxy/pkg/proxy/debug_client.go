package proxy

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"

	"strange.industries/go-proxy/pkg/controller"
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
	log.Printf("POST %s", url)
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(input))
	if err != nil {
		return nil, err
	}
	return io.ReadAll(resp.Body)
}

func (p *DebugClientProxy) GetSpeed() *controller.GetSpeedResponse {
	log.Printf("/GetSpeed")
	in, err := json.Marshal(struct{}{})
	if err != nil {
		log.Fatalln("Could not marshal request")
	}
	out, err := p.CallCommand("GetSpeed", in)
	var resp *controller.GetSpeedResponse
	json.Unmarshal(out, &resp)
	if err != nil {
		log.Fatalln("Could not unmarshal response")
	}
	return resp
}

func (p *DebugClientProxy) GetRecentFlows() []controller.FlowData {
	log.Printf("/GetRecentFlows")
	in, err := json.Marshal(struct{}{})
	if err != nil {
		log.Fatalln("Could not marshal request")
	}
	out, err := p.CallCommand("GetRecentFlows", in)
	var resp []controller.FlowData
	json.Unmarshal(out, &resp)
	if err != nil {
		log.Fatalln("Could not unmarshal response")
	}
	return resp
}

func (p *DebugClientProxy) Pause() {
	req, err := json.Marshal(struct{}{})
	if err != nil {
		log.Fatalln("Could not marshal request")
	}
	_, err = p.CallCommand("Pause", req)
	if err != nil {
		log.Fatalln("Could not unmarshal response")
	}
	return
}
