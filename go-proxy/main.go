package main

import (
	b64 "encoding/base64"
	"fmt"
	"log"
	"net"

	"os"

	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
	"golang.zx2c4.com/go118/netip"
	"golang.zx2c4.com/wireguard/tun"
	"golang.zx2c4.com/wireguard/tun/netstack"
)

type Server struct {
	conn *net.UDPConn
	tun  tun.Device
	tnet *netstack.Net
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
			if ipv4Layer := packet.Layer(layers.LayerTypeIPv4); ipv4Layer != nil {
				fmt.Println("This is a ipv4 packet!")
				ipv4, _ := ipv4Layer.(*layers.IPv4)
				fmt.Printf("From src address %d to dst address %d\n", ipv4.SrcIP, ipv4.DstIP)
			}
			if ipv6Layer := packet.Layer(layers.LayerTypeIPv6); ipv6Layer != nil {
				fmt.Println("This is a ipv6 packet!")
				ipv6, _ := ipv6Layer.(*layers.IPv6)
				fmt.Printf("From src address %d to dst address %d\n", ipv6.SrcIP, ipv6.DstIP)
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
			_, err := c.tun.Write(data[:n], 0)
			if err != nil {
				fmt.Printf("bad write: %s", err)
			}
		}
	}
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	tun, tnet, err := netstack.CreateNetTUN(
		[]netip.Addr{netip.MustParseAddr("10.0.0.8")},
		[]netip.Addr{netip.MustParseAddr("8.8.8.8")}, // DNS
		1500)
	if err != nil {
		log.Panicln(err)
	}

	// TODO: configure TUN to write packets forward
	// TODO: listen on TUN to write packets back

	conn, err := net.ListenUDP("udp", &net.UDPAddr{IP: netip.MustParseAddr("0.0.0.0").AsSlice(), Port: 8080})
	if err != nil {
		log.Fatalf("Udp Service listen report udp fail:%v", err)
	}
	defer conn.Close()

	log.Printf("Listening on port %s", port)
	server := Server{conn: conn, tun: tun, tnet: tnet}
	server.Listen()
}
