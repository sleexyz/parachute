// Local proxy
package main

import (
	"log"
	"strconv"

	"os"

	"net/http"
	_ "net/http/pprof"

	"strange.industries/go-proxy/singleton"
)

func main() {
	portStr := os.Getenv("PORT")
	if portStr == "" {
		portStr = "8080"
	}
	port, err := strconv.Atoi(portStr)
	if err != nil {
		log.Panicln("could not parse $PORT")
	}
	singleton.MaxProcs(1)
	singleton.SetMemoryLimit(10 << 20)
	singleton.SetGCPercent(20)
	defer singleton.Close()
	go func() {
		singleton.Start(port)
	}()
	http.ListenAndServe("localhost:6060", nil)
}
