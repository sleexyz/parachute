package Proxy

import (
	"log"

	"strange.industries/go-proxy/router"
	"strange.industries/go-proxy/tunconn"
)

type Proxy interface {
	Start()
	Close()
}

var serverProxy *ServerProxy

type ServerProxy struct {
	i tunconn.TunConn
	c *router.Router
}

func (p *ServerProxy) Start(port int) {
	i, err := tunconn.InitUDPServerConn(port)
	if err != nil {
		log.Fatalf("Could not initialize internal connection: %v", err)
	}
	p.i = i
	p.c = router.Init("10.0.0.8", i)
	p.c.Start()
}

func (p *ServerProxy) Close() {
	p.i.Close()
}

func Start(port int) {
	serverProxy = &ServerProxy{}
	serverProxy.Start(port)
}

func Close() {
	serverProxy.Close()
}
