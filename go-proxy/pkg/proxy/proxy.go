package proxy

import (
	"strange.industries/go-proxy/pkg/analytics"
	"strange.industries/go-proxy/pkg/controller"
	"strange.industries/go-proxy/pkg/logger"
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
	GetRecentFlows() []analytics.Flow
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
		logger.Logger.Fatalf("Could not initialize internal connection: %v", err)
	}
	p.i = i
	logger.Logger.Printf("Listening on port %d", port)
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

func (p *ServerProxy) GetRecentFlows() []analytics.Flow {
	return p.Router.Analytics.GetRecentFlows()
}

func (p *ServerProxy) Pause() {
	go p.Router.Controller.Pause()
}
