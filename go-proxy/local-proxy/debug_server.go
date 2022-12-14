package main

import (
	"bytes"
	"fmt"
	"net/http"
	"regexp"
	"time"

	ffi "strange.industries/go-proxy/pkg/ffi"
	"strange.industries/go-proxy/pkg/logger"
	"strange.industries/go-proxy/pkg/proxy"
)

var (
	debugPort = "8083"
)

type DebugServerProxy struct {
	proxyBridge ffi.ProxyBridge
	proxy       proxy.Proxy
}

func InitDebugServerProxy(proxyBridge ffi.ProxyBridge, proxy proxy.Proxy) *DebugServerProxy {
	return &DebugServerProxy{proxyBridge: proxyBridge, proxy: proxy}
}

func (p *DebugServerProxy) Start(port int) {
	go p.proxy.Start(port)
	p.serveDebugHandlers()
	// Start http server
}

func (p *DebugServerProxy) Close() {
	p.proxy.Close()
}

func (p *DebugServerProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	regexp, _ := regexp.Compile("^/Command/([a-zA-Z]+)$")
	match := regexp.FindStringSubmatch(r.URL.Path)
	if len(match) < 2 {
		http.Error(w, "No command found", http.StatusNotFound)
		return
	}
	var buf bytes.Buffer
	buf.ReadFrom(r.Body)
	out := p.proxyBridge.Command(match[1], buf.Bytes())
	logger.Logger.Printf("%s %s", match[1], buf.String())
	w.Header().Set("Content-Type", "application/json")
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
	logger.Logger.Printf("Serving debug requests at port %s\n", debugPort)
	logger.Logger.Fatal(s.ListenAndServe())
}
