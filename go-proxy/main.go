package main

import (
	b64 "encoding/base64"
	"fmt"
	"log"
	"net"
	"net/netip"
	"os"

	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
)

type Server struct {
	conn *net.UDPConn
}

func (c *Server) Listen() {
	for {
		data := make([]byte, 1024*4)
		n, _, err := c.conn.ReadFromUDP(data)
		if err == nil {
			sEnc := b64.StdEncoding.EncodeToString([]byte(data[:n]))
			fmt.Println(sEnc)

			ipVersion := (data[0] & 0xf0) >> 4
			var packet gopacket.Packet
			if ipVersion == 6 {
				packet = gopacket.NewPacket(data[:n], layers.LayerTypeIPv6, gopacket.Default)
			} else {
				packet = gopacket.NewPacket(data[:n], layers.LayerTypeIPv4, gopacket.Default)
			}
			if tcpLayer := packet.Layer(layers.LayerTypeTCP); tcpLayer != nil {
				fmt.Println("This is a TCP packet!")
				// Get actual TCP data from this layer
				tcp, _ := tcpLayer.(*layers.TCP)
				fmt.Printf("From src port %d to dst port %d\n", tcp.SrcPort, tcp.DstPort)
			}
			// Iterate over all layers, printing out each layer type
			for _, layer := range packet.Layers() {
				fmt.Println("PACKET LAYER:", layer.LayerType())
			}
			// conn.WriteToUDP(data[:n], remoteAddr)
		}
	}
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// tun, tnet, err := netstack.CreateNetTUN(
	// 	[]netip.Addr{netip.MustParseAddr("0.0.0.0")},
	// 	[]netip.Addr{netip.MustParseAddr("8.8.8.8")},
	// 	8080)
	// if err != nil {
	// 	log.Panicln(err)
	// }
	// tun.write
	// listener, err := tnet.ListenUDP(&net.UDPAddr{Port: port})
	// if err != nil {
	// 	log.Panicln(err)
	// }

	conn, err := net.ListenUDP("udp", &net.UDPAddr{IP: netip.MustParseAddr("0.0.0.0").AsSlice(), Port: 8080})
	if err != nil {
		log.Fatalf("Udp Service listen report udp fail:%v", err)
	}
	defer conn.Close()

	log.Printf("Listening on port %s", port)
	server := Server{conn: conn}
	server.Listen()
}
