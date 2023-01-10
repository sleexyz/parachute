package proxy

import (
	"log"

	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
	"strange.industries/go-proxy/pkg/controller"
	"strange.industries/go-proxy/pkg/router"
	"strange.industries/go-proxy/pkg/tunconn"
)

const (
	proxyAddr = "10.0.0.8"
)

type Proxy struct {
	analytics.Analytics
	*controller.Controller
	i      tunconn.TunConn
	router *router.Router
}

func InitOnDeviceProxy(a analytics.Analytics, controller *controller.Controller) *Proxy {
	return &Proxy{
		Controller: controller,
		Analytics:  a,
	}
}

func (p *Proxy) Start(i tunconn.TunConn, s *proxyservice.Settings) {
	log.Printf("Starting proxy")
	p.Controller.SetSettings(s)
	p.i = i
	p.router = router.Init(proxyAddr, i, p.Controller)
	go p.router.Start()
}

func (p *Proxy) StartUDPServer(port int, s *proxyservice.Settings) {
	i, err := tunconn.InitUDPServerConn(port)
	if err != nil {
		log.Fatalf("Could not initialize internal connection: %v", err)
	}
	defer log.Printf("Listening on port %d", port)
	p.Start(i, s)
}

func (p *Proxy) Close() {
	p.Analytics.Close()
	p.router.Close()
	p.i.Close()
}
