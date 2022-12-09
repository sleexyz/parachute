package main

import (
	"fmt"
	"log"
	"net/http"
	"time"

	"strange.industries/go-proxy/pkg/ffi"
)

var (
	debugPort = "8083"
)

func serveDebugHandlers() {
	mux := http.NewServeMux()
	mux.HandleFunc("/GetRecentFlows", func(w http.ResponseWriter, r *http.Request) {
		log.Println("/GetRecentFlows")
		flows := ffi.GetRecentFlows()
		w.Header().Set("Content-Type", "application/json")
		_, err := w.Write(flows)
		if err != nil {
			http.Error(w, fmt.Sprintf("unexpected error: %v", err), http.StatusInternalServerError)
		}
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
