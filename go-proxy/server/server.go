package server

import (
	"context"
	"fmt"
	"log"
	"sync"

	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
	"strange.industries/go-proxy/adapter"
	"strange.industries/go-proxy/external"
	"strange.industries/go-proxy/forwarder"
	"strange.industries/go-proxy/internal"

	"gvisor.dev/gvisor/pkg/bufferv2"
	"gvisor.dev/gvisor/pkg/tcpip"
	"gvisor.dev/gvisor/pkg/tcpip/link/channel"
	"gvisor.dev/gvisor/pkg/tcpip/network/ipv4"
	"gvisor.dev/gvisor/pkg/tcpip/network/ipv6"
	"gvisor.dev/gvisor/pkg/tcpip/stack"
)

const (
	defaultMTU = 1500
)

type Server struct {
	// internal (device <=> proxy)
	i internal.Conn

	// external (proxy <=> internet)
	stack    *stack.Stack
	tcpQueue chan adapter.TCPConn
	udpQueue chan adapter.UDPConn
	ep       *channel.Endpoint
}

func Init(address string, i internal.Conn) *Server {
	ep := channel.New(10, defaultMTU, "10.0.0.8")
	tcpQueue := make(chan adapter.TCPConn)
	udpQueue := make(chan adapter.UDPConn)

	// With high mtu, low packet loss and low latency over tuntap,
	// the specific value isn't that important. The only important
	// bit is that it should be at least a couple times MSS.
	bufSize := 4 * 1024 * 1024

	s, err := external.CreateStack(ep, tcpQueue, udpQueue, bufSize, bufSize)
	if err != nil {
		log.Panicln(err)
	}

	server := Server{
		// external
		stack:    s,
		tcpQueue: tcpQueue,
		udpQueue: udpQueue,
		ep:       ep,

		// internal
		i: i,
	}

	return &server
}

func (c *Server) ListenInternal() {
	wg := new(sync.WaitGroup)
	wg.Add(2)
	ctx, cancel := context.WithCancel(context.Background())
	// forward packet from client to stack
	go func() {
		defer wg.Done()
		defer cancel()
		for {
			data := make([]byte, 1024*4)
			n, err := c.i.Read(data)
			if err != nil {
				fmt.Printf("(outbound) bad read: %s\n", err)
				break
			}
			_, err = c.WriteToStack(data[:n])
			if err != nil {
				fmt.Printf("(outbound) bad write: %s\n", err)
				break
			}
		}
	}()
	// forward packet from stack to client
	go func() {
		defer wg.Done()
		for {
			pkt := c.ep.ReadContext(ctx)
			if pkt == nil {
				break
			}
			c.WriteInboundPacket(pkt)
		}
	}()
	wg.Wait()
}

func (c *Server) WriteInboundPacket(pkt *stack.PacketBuffer) tcpip.Error {
	defer pkt.DecRef()
	buf := pkt.ToBuffer()
	defer buf.Release()
	data := buf.Flatten()
	debugString := MakeDebugString(data)
	_, err := c.i.Write(data)
	if err != nil {
		fmt.Printf("(inbound) %s, error:%s\n", debugString, err)
		return &tcpip.ErrInvalidEndpointState{}
	}
	return nil
}

func (c *Server) WriteToStack(b []byte) (int, error) {
	if len(b) == 0 {
		return 0, nil
	}
	pkb := stack.NewPacketBuffer(stack.PacketBufferOptions{
		Payload: bufferv2.MakeWithData(b),
	})
	switch b[0] >> 4 {
	case 4:
		c.ep.InjectInbound(ipv4.ProtocolNumber, pkb)
	case 6:
		c.ep.InjectInbound(ipv6.ProtocolNumber, pkb)
	}
	pkb.DecRef()
	return len(b), nil
}

// Initializes channel handlers
func (c *Server) ListenExternal() {
	go func() {
		for {
			select {
			case conn := <-c.tcpQueue:
				go forwarder.HandleTCPConn(conn)
			case conn := <-c.udpQueue:
				go forwarder.HandleUDPConn(conn)
			}
		}
	}()
}

func MakeDebugString(data []byte) string {
	// sEnc := base64.StdEncoding.EncodeToString([]byte(data[:n]))
	// fmt.Printf("-------- %s\n", sEnc)
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
	if protocol != "" {
		return fmt.Sprintf("%s -- %s:%s->%s:%s", protocol, srcAddr, srcPort, dstAddr, dstPort)
	}
	return ""
}
