package main

import (
	"log"
	"net"

	"os"

	"golang.zx2c4.com/go118/netip"
	"strange.industries/go-proxy/server"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	iConn, err := net.ListenUDP("udp", &net.UDPAddr{IP: netip.MustParseAddr("0.0.0.0").AsSlice(), Port: 8080})
	if err != nil {
		log.Fatalf("Udp Service listen report udp fail:%v", err)
	}
	defer iConn.Close()
	log.Printf("Listening on port %s", port)

	c := server.Init("10.0.0.8", iConn)
	c.ListenExternal()
	c.ListenInternal()
}
