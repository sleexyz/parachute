package singleton

import (
	proxy "strange.industries/go-proxy/proxy"
)

var p proxy.Proxy

func Start(port int) {
	p = &proxy.ServerProxy{}
	p.Start(port)
}

func Close() {
	p.Close()
}
