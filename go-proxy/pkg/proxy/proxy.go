package proxy

import (
	"encoding/json"
	"log"

	"strange.industries/go-proxy/pkg/router"
	"strange.industries/go-proxy/pkg/tunconn"
)

const (
	proxyAddr = "10.0.0.8"
)

type ServerProxy struct {
	i      tunconn.TunConn
	Router *router.Router
}

func (p *ServerProxy) Start(port int) {
	i, err := tunconn.InitUDPServerConn(port)
	if err != nil {
		log.Fatalf("Could not initialize internal connection: %v", err)
	}
	p.i = i
	log.Printf("Listening on port %d", port)
	p.Router = router.Init(proxyAddr, i)
	p.Router.Start()
}

func (p *ServerProxy) Close() {
	p.i.Close()
	p.Router.Close()
}

func (p *ServerProxy) GetRecentFlows() []byte {
	flows := p.Router.Analytics.GetRecentFlows()
	out, err := json.MarshalIndent(flows, "", "  ")
	if err != nil {
		return nil
	}
	return out
}

func (p *ServerProxy) SetLatency(ms int) {
	p.Router.Controller.SetLatency(ms)
}
