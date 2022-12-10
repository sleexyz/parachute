package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"strange.industries/go-proxy/pkg/proxy"
)

var (
	debugPort = "8083"
)

type DebugServerProxy struct {
	proxy.ServerProxy
}

func (p *DebugServerProxy) Start(port int) {
	go p.ServerProxy.Start(port)
	p.serveDebugHandlers()
	// Start http server
}

func (p *DebugServerProxy) serveDebugHandlers() {
	mux := http.NewServeMux()
	mux.HandleFunc("/GetRecentFlows", func(w http.ResponseWriter, r *http.Request) {
		log.Println("/GetRecentFlows")
		flows := p.GetRecentFlows()
		w.Header().Set("Content-Type", "application/json")
		_, err := w.Write(flows)
		if err != nil {
			http.Error(w, fmt.Sprintf("unexpected error: %v", err), http.StatusInternalServerError)
		}
	})
	mux.HandleFunc("/SetLatency", func(w http.ResponseWriter, r *http.Request) {
		var ms int
		err := json.NewDecoder(r.Body).Decode(&ms)
		if err != nil {
			http.Error(w, fmt.Sprintf("unexpected error: %v", err), http.StatusInternalServerError)
		}
		log.Printf("/SetLatency: %dms", ms)
		p.SetLatency(ms)
		w.WriteHeader(http.StatusOK)
		// w.Header().Set("Content-Type", "application/json")
		// _, err := w.Write([])
		// if err != nil {
		// 	http.Error(w, fmt.Sprintf("unexpected error: %v", err), http.StatusInternalServerError)
		// }
	})
	s := &http.Server{
		Addr:           fmt.Sprintf(":%s", debugPort),
		Handler:        mux,
		ReadTimeout:    10 * time.Second,
		WriteTimeout:   10 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}
	log.Printf("Serving debug requests at port %s\n", debugPort)
	log.Fatal(s.ListenAndServe())
}
