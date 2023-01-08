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

func (p *Proxy) Start(port int, s *proxyservice.Settings) {
	p.Controller.SetSettings(s)
	i, err := tunconn.InitUDPServerConn(port)
	if err != nil {
		log.Fatalf("Could not initialize internal connection: %v", err)
	}
	p.i = i
	log.Printf("Listening on port %d", port)
	p.router = router.Init(proxyAddr, i, p.Controller)
	p.router.Start()
}

func (p *Proxy) Close() {
	p.Analytics.Close()
	p.router.Close()
	p.i.Close()
}
