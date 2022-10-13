package main

import (
	"log"
	"strconv"

	"os"

	"strange.industries/go-proxy/internal"
	"strange.industries/go-proxy/server"
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

	i, err := internal.InitUDPIConnWithPcapPipe(port, "/tmp/goproxy.pcapng")
	if err != nil {
		log.Fatalf("Could not initialize internal connection: %v", err)
	}
	i.WriteLoop()
	defer i.Close()
	log.Printf("Listening on port %s", portStr)

	c := server.Init("10.0.0.8", i)

	c.ListenExternal()
	c.ListenInternal()
}
