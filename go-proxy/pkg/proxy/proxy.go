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
	// GetRecentFlows() []controller.FlowData
	SetRxSpeedTarget(target float64)
	SetTemporaryRxSpeedTarget(target float64, seconds int)
}

type ServerProxy struct {
	controller.Controller
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
