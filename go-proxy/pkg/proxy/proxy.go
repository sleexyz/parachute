package proxy

import (
	"log"

	"strange.industries/go-proxy/pkg/controller"
	"strange.industries/go-proxy/pkg/router"
	"strange.industries/go-proxy/pkg/tunconn"
)

const (
	proxyAddr = "10.0.0.8"
)

type Proxy interface {
	Start(port int)
	Close()
	GetSpeed() *controller.GetSpeedResponse
	GetRecentFlows() []controller.FlowData
	Pause()
}

type ServerProxy struct {
	i      tunconn.TunConn
	Router *router.Router
}

func InitServerProxy() *ServerProxy {
	return &ServerProxy{}
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

func (p *ServerProxy) GetSpeed() *controller.GetSpeedResponse {
	return p.Router.Controller.GetSpeed()
}

func (p *ServerProxy) GetRecentFlows() []controller.FlowData {
	return []controller.FlowData{}
}

func (p *ServerProxy) Pause() {
	go p.Router.Controller.Pause()
}
