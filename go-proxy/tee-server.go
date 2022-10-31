package main

import (
	"log"
	"os"
	"strconv"

	"strange.industries/go-proxy/tee"
	"strange.industries/go-proxy/tunconn"
)

const (
	sinkPort        = 8082
	outboundAddress = "127.0.0.1:8081"
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

	i1, err := tunconn.InitUDPServerConn(port)
	if err != nil {
		log.Fatalf("Could not initialize internal connection: %v", err)
	}
	defer i1.Close()
	log.Printf("Listening for inbound packets port %s", portStr)

	sink, err := tunconn.InitTCPServerSink(sinkPort)
	if err != nil {
		log.Fatalf("Could not initialize TCPServerSink: %v", err)
	}
	sink.Listen()
	log.Printf("Listening for sink connections at port %v", sinkPort)
	i := tunconn.InitDuplexTee(i1, sink)
	i.WriteLoop()

	// i, err := tunconn.InitWithPcapPipe(i1, "/tmp/goproxy.pcapng")
	// if err != nil {
	// 	log.Fatalf("Could not initialize internal connection: %v", err)
	// }

	t, err := tee.InitTee(i, outboundAddress)
	if err != nil {
		log.Fatalf("Could not initialize outbound connection: %v", err)
	}
	log.Printf("Forwarding packets over udp to %s", outboundAddress)
	t.Listen()
	// defer t.Close()
}
