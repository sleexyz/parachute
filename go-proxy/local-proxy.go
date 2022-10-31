// Local proxy
package main

import (
	"log"
	"strconv"

	"os"

	"strange.industries/go-proxy/proxy"
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
	p := &proxy.ServerProxy{}
	p.Start(port)
	defer p.Close()
}
