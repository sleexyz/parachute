package main

import (
	"bytes"
	"fmt"
	"log"
	"net/http"
	"regexp"
	"time"

	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/controller"
	ffi "strange.industries/go-proxy/pkg/ffi"
	"strange.industries/go-proxy/pkg/proxy"
)

var (
	debugPort = "8083"
)

type DebugServerProxy struct {
	proxyBridge ffi.ProxyBridge
	proxy       *proxy.Proxy
}

func InitDebugServerProxy(proxyBridge ffi.ProxyBridge, proxy *proxy.Proxy) *DebugServerProxy {
	return &DebugServerProxy{proxyBridge: proxyBridge, proxy: proxy}
}

func (p *DebugServerProxy) Start(port int) {
	startRequest := &proxyservice.Settings{
		DefaultPreset: &proxyservice.Preset{
			BaseRxSpeedTarget: controller.DefaultRxSpeedTarget,
		},
	}
	go p.proxy.StartUDPServer(port, startRequest)
	p.serveDebugHandlers()
	// Start http server
}

func (p *DebugServerProxy) Close() {
	p.proxy.Close()
}

func (p *DebugServerProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	regexp, _ := regexp.Compile("^/Rpc$")
	match := regexp.FindString(r.URL.Path)
	if match == "" {
		http.Error(w, "Not found", http.StatusNotFound)
		return
	}
	var buf bytes.Buffer
	buf.ReadFrom(r.Body)
	out := p.proxyBridge.Rpc(buf.Bytes())
	w.Header().Set("Content-Type", "application/octet-stream")
	_, err := w.Write(out)
	if err != nil {
		http.Error(w, fmt.Sprintf("unexpected error: %v", err), http.StatusInternalServerError)
	}
}

func (p *DebugServerProxy) serveDebugHandlers() {
	mux := http.NewServeMux()
	mux.HandleFunc("/Command", func(w http.ResponseWriter, r *http.Request) {
	})
	s := &http.Server{
		Addr:           fmt.Sprintf(":%s", debugPort),
		Handler:        p,
		ReadTimeout:    10 * time.Second,
		WriteTimeout:   10 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}
	log.Printf("Serving debug requests at port %s\n", debugPort)
	log.Fatal(s.ListenAndServe())
}
