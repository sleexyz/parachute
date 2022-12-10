package proxy

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
)

type DebugClientProxy struct {
	DebugServerAddr string
	Log             *log.Logger
}

func (p *DebugClientProxy) Start(port int) {
}

func (p *DebugClientProxy) Close() {
}

func (p *DebugClientProxy) GetRecentFlows() []byte {
	p.Log.Printf("/GetRecentFlows")
	resp, err := http.Get(fmt.Sprintf("http://%s/GetRecentFlows", p.DebugServerAddr))
	if err != nil {
		p.Log.Fatalln(err)
	}

	b, err := io.ReadAll(resp.Body)
	if err != nil {
		p.Log.Fatalln(err)
	}
	return b
}

func (p *DebugClientProxy) SetLatency(ms int) {
	p.Log.Printf("/SetLatency")
	body, err := json.Marshal(ms)
	if err != nil {
		p.Log.Fatalln(err)
	}
	_, err = http.Post(fmt.Sprintf("http://%s/SetLatency", p.DebugServerAddr), "application/json", bytes.NewBuffer(body))
	if err != nil {
		p.Log.Fatalln(err)
	}
}
