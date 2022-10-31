package proxy

import (
	"log"

	"strange.industries/go-proxy/tee"
	"strange.industries/go-proxy/tunconn"
)

type TeeProxy struct {
	i tunconn.TunConn
	t *tee.Tee
}

func (p *TeeProxy) Start(iport int, oaddress string) {
	i, err := tunconn.InitUDPServerConn(iport)
	if err != nil {
		log.Fatalf("Could not initialize internal connection: %v", err)
	}
	p.i = i
	log.Printf("Listening on port %d", iport)

	t, err := tee.InitTee(i, oaddress)
	if err != nil {
		log.Fatalf("Could not initialize external connection: %v", err)
	}
	p.t = t
	p.t.Listen()
}

func (p *TeeProxy) Close() {
	p.i.Close()
	p.t.Close()
}
