package proxy

import (
	"log"

	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/controller"
	"strange.industries/go-proxy/pkg/router"
	"strange.industries/go-proxy/pkg/tunconn"
)

const (
	proxyAddr = "10.0.0.8"
)

type Proxy interface {
	controller.ControllerSettingsReadWrite
	Start(port int, startRequest *proxyservice.Settings)
	Close()
}

type ServerProxy struct {
	controller.Controller
	i      tunconn.TunConn
	router *router.Router
}

func InitServerProxy() *ServerProxy {
	return &ServerProxy{
		Controller: *controller.Init(),
	}
}

func (p *ServerProxy) Start(port int, s *proxyservice.Settings) {
	if s.BaseRxSpeedTarget > 0 {
		p.Controller.SetBaseRxSpeedTarget(s.BaseRxSpeedTarget)
	}

	i, err := tunconn.InitUDPServerConn(port)
	if err != nil {
		log.Fatalf("Could not initialize internal connection: %v", err)
	}
	p.i = i
	log.Printf("Listening on port %d", port)
	p.router = router.Init(proxyAddr, i, &p.Controller)
	p.router.Start()
}

func (p *ServerProxy) Close() {
	p.i.Close()
	p.router.Close()
}
