package singleton

import (
	proxy "strange.industries/go-proxy/proxy"
)

var p *proxy.TeeProxy

func Start(port int, oaddress string) {
	p = &proxy.TeeProxy{}
	p.Start(port, oaddress)
}

func Close() {
	p.Close()
}
