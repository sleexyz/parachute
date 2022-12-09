package proxy

import (
	"log"

	"strange.industries/go-proxy/pkg/router"
	"strange.industries/go-proxy/pkg/tunconn"
)

const (
	proxyAddr = "10.0.0.8"
)

type ServerProxy struct {
	i tunconn.TunConn
	C *router.Router
}

func (p *ServerProxy) Start(port int) {
	i, err := tunconn.InitUDPServerConn(port)
	if err != nil {
		log.Fatalf("Could not initialize internal connection: %v", err)
	}
	p.i = i
	log.Printf("Listening on port %d", port)
	p.C = router.Init(proxyAddr, i)
	p.C.Start()
}

func (p *ServerProxy) Close() {
	p.i.Close()
	p.C.Close()
}
