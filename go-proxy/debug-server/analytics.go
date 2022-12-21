package main

import (
	"context"
	"fmt"
	"log"
	"net/http"

	"github.com/r3labs/sse/v2"
	"google.golang.org/protobuf/encoding/protojson"
	"strange.industries/go-proxy/pb/proxyservice"
)

type AnalyticsServer struct {
	port    int
	sse     *sse.Server
	mux     *http.ServeMux
	samples chan (*proxyservice.Sample)
	cancel  context.CancelFunc
}

func InitAnalyticsServer(port int) *AnalyticsServer {
	s := sse.New()
	s.CreateStream("samples")
	mux := http.NewServeMux()
	mux.HandleFunc("/events", func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("origin")
		log.Printf("Connection from %s", origin)
		if origin == "http://localhost:5173" {
			w.Header().Add("Access-Control-Allow-Origin", origin)
		}
		s.ServeHTTP(w, r)
	})
	return &AnalyticsServer{
		port:    port,
		sse:     s,
		mux:     mux,
		samples: make(chan *proxyservice.Sample),
	}
}

// Must be started manually
func (a *AnalyticsServer) Start() {
	ctx, cancel := context.WithCancel(context.Background())
	a.cancel = cancel

	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			case sample := <-a.samples:
				// log.Printf("Processing Sample: %s", sample)
				data, err := protojson.Marshal(sample)
				if err != nil {
					log.Fatalf("Error marshalling sample data: %s", sample)
				}
				a.sse.Publish("samples", &sse.Event{
					Data: data,
				})
			}
		}
	}()
	go func() {
		http.ListenAndServe(fmt.Sprintf(":%d", a.port), a.mux)
	}()
	log.Printf("Started analytics server")
}

func (a *AnalyticsServer) Close() {
	if a.cancel != nil {
		a.cancel()
		a.cancel = nil
	}
}

func (a *AnalyticsServer) PublishSample(sample *proxyservice.Sample) {
	a.samples <- sample
}
