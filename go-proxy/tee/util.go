package tee

import (
	"encoding/base64"
	"fmt"
	"log"

	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
)

func LogPacket(label string, data []byte) {
	sEnc := base64.StdEncoding.EncodeToString(data)
	log.Printf("%s -------- %s\n", label, sEnc)
	log.Printf("%s: %s", label, MakeDebugString(data))
}

func MakeDebugString(data []byte) string {
	ipVersion := (data[0] & 0xf0) >> 4
	var packet gopacket.Packet
	if ipVersion == 6 {
		packet = gopacket.NewPacket(data, layers.LayerTypeIPv6, gopacket.Default)
	} else {
		packet = gopacket.NewPacket(data, layers.LayerTypeIPv4, gopacket.Default)
	}
	var srcAddr, dstAddr, srcPort, dstPort, protocol string
	if ipv4Layer := packet.Layer(layers.LayerTypeIPv4); ipv4Layer != nil {
		ipv4, _ := ipv4Layer.(*layers.IPv4)
		srcAddr = ipv4.SrcIP.String()
		dstAddr = ipv4.DstIP.String()
	}
	if ipv6Layer := packet.Layer(layers.LayerTypeIPv6); ipv6Layer != nil {
		ipv6, _ := ipv6Layer.(*layers.IPv6)
		srcAddr = ipv6.SrcIP.String()
		dstAddr = ipv6.DstIP.String()
	}
	if tcpLayer := packet.Layer(layers.LayerTypeTCP); tcpLayer != nil {
		tcp, _ := tcpLayer.(*layers.TCP)
		srcPort = tcp.SrcPort.String()
		dstPort = tcp.DstPort.String()
		protocol = "tcp"
	}
	if udpLayer := packet.Layer(layers.LayerTypeUDP); udpLayer != nil {
		udp, _ := udpLayer.(*layers.UDP)
		srcPort = udp.SrcPort.String()
		dstPort = udp.DstPort.String()
		protocol = "udp"
	}
	if dstPort == "53(domain)" {
		return fmt.Sprintf("%s -- %s:%s->%s:%s", protocol, srcAddr, srcPort, dstAddr, dstPort)
	}
	return ""
}
