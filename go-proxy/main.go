package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"sync"
	"time"

	"os"

	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
	"golang.zx2c4.com/go118/netip"
	"strange.industries/go-proxy/adapter"
	"strange.industries/go-proxy/forwarder"

	"gvisor.dev/gvisor/pkg/bufferv2"
	"gvisor.dev/gvisor/pkg/tcpip"
	"gvisor.dev/gvisor/pkg/tcpip/adapters/gonet"
	"gvisor.dev/gvisor/pkg/tcpip/header"
	"gvisor.dev/gvisor/pkg/tcpip/link/channel"
	"gvisor.dev/gvisor/pkg/tcpip/network/ipv4"
	"gvisor.dev/gvisor/pkg/tcpip/network/ipv6"
	"gvisor.dev/gvisor/pkg/tcpip/stack"
	"gvisor.dev/gvisor/pkg/tcpip/transport/icmp"
	"gvisor.dev/gvisor/pkg/tcpip/transport/tcp"
	"gvisor.dev/gvisor/pkg/tcpip/transport/udp"
	"gvisor.dev/gvisor/pkg/waiter"
)

type tcpConn struct {
	*gonet.TCPConn
	id stack.TransportEndpointID
}

func (c *tcpConn) ID() *stack.TransportEndpointID {
	return &c.id
}

type udpConn struct {
	*gonet.UDPConn
	id stack.TransportEndpointID
}

func (c *udpConn) ID() *stack.TransportEndpointID {
	return &c.id
}

type Server struct {
	tcpQueue       chan adapter.TCPConn
	udpQueue       chan adapter.UDPConn
	inboundUDPAddr *net.UDPAddr
	ep             *channel.Endpoint
	cConn          *net.UDPConn
	stack          *stack.Stack
}

// Initializes outbound channel handlers
func (c *Server) InitOutboundHandlers() {
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

func (c *Server) WriteOutboundData(buf []byte, offset int) (int, error) {
	packet := buf[offset:]
	if len(packet) == 0 {
		return 0, nil
	}
	pkb := stack.NewPacketBuffer(stack.PacketBufferOptions{
		Payload: bufferv2.MakeWithData(packet),
	})
	// c.ep.WriteRawPacket(pkb)
	switch packet[0] >> 4 {
	case 4:
		c.ep.InjectInbound(ipv4.ProtocolNumber, pkb)
	case 6:
		c.ep.InjectInbound(ipv6.ProtocolNumber, pkb)
	}
	pkb.DecRef()
	return len(buf), nil
}

func (c *Server) Listen() {
	// for {
	// Use wait groups to alternative between inbound and outbound loops.
	wg := new(sync.WaitGroup)
	wg.Add(2)
	ctx, cancel := context.WithCancel(context.Background())
	go func() {
		c.InboundLoop(ctx)
		wg.Done()
	}()
	go func() {
		c.OutboundLoop(cancel)
		wg.Done()
	}()
	wg.Wait()
	// }
}

func (c *Server) InboundLoop(ctx context.Context) {
	for {
		pkt := c.ep.ReadContext(ctx)
		if pkt == nil {
			break
		}
		if c.inboundUDPAddr != nil {
			c.WriteInboundPacket(pkt, c.inboundUDPAddr)
		}
	}
}

func (c *Server) WriteInboundPacket(pkt *stack.PacketBuffer, addr *net.UDPAddr) tcpip.Error {
	defer pkt.DecRef()
	buf := pkt.ToBuffer()
	defer buf.Release()
	data := buf.Flatten()
	debugString := makeDebugString(data)
	bw, err := c.cConn.WriteTo(data, addr)
	if err != nil {
		fmt.Printf("<= %s, error:%s\n", debugString, err)
		return &tcpip.ErrInvalidEndpointState{}
	}
	fmt.Printf("<= %s, bytes written:%d\n", debugString, bw)
	return nil
}

func makeDebugString(data []byte) string {
	// sEnc := base64.StdEncoding.EncodeToString([]byte(data[:n]))
	// fmt.Printf("-------- %s\n", sEnc)
	// if true {
	// 	return ""
	// }
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

func (c *Server) OutboundLoop(cancel context.CancelFunc) {
	defer cancel()
	for {
		data := make([]byte, 1024*4)
		n, addr, err := c.cConn.ReadFromUDP(data)
		if err != nil {
			fmt.Printf("=> bad write: %s\n", err)
			break
		}
		c.inboundUDPAddr = addr
		_, err = c.WriteOutboundData(data[:n], 0)
		if err != nil {
			fmt.Printf("=> bad write: %s\n", err)
			break
		}
		// debugString := makeDebugString(data[:n])
		// fmt.Printf("=> %s, bytes written: %d\n", debugString, bw)
	}
}

const (
	defaultMTU = 1500

	// defaultWndSize if set to zero, the default
	// receive window buffer size is used instead.
	defaultWndSize = 0

	// maxConnAttempts specifies the maximum number
	// of in-flight tcp connection attempts.
	// maxConnAttempts = 10
	maxConnAttempts = 2 << 10

	// tcpKeepaliveCount is the maximum number of
	// TCP keep-alive probes to send before giving up
	// and killing the connection if no response is
	// obtained from the other end.
	tcpKeepaliveCount = 9

	// tcpKeepaliveIdle specifies the time a connection
	// must remain idle before the first TCP keepalive
	// packet is sent. Once this time is reached,
	// tcpKeepaliveInterval option is used instead.
	// tcpKeepaliveIdle = 60 * time.Second
	tcpKeepaliveIdle = 60 * time.Second

	// tcpKeepaliveInterval specifies the interval
	// time between sending TCP keepalive packets.
	tcpKeepaliveInterval = 30 * time.Second

	// defaultTimeToLive specifies the default TTL used by stack.
	defaultTimeToLive uint8 = 64
)

func createStack(ep *channel.Endpoint, tcpQueue chan adapter.TCPConn, udpQueue chan adapter.UDPConn, rcvBufferSize int, sndBufferSize int) (*stack.Stack, error) {
	s := stack.New(stack.Options{
		NetworkProtocols:   []stack.NetworkProtocolFactory{ipv4.NewProtocol, ipv6.NewProtocol},
		TransportProtocols: []stack.TransportProtocolFactory{tcp.NewProtocol, udp.NewProtocol, icmp.NewProtocol6, icmp.NewProtocol4},
		HandleLocal:        false,
	})
	s.SetForwardingDefaultAndAllNICs(ipv4.ProtocolNumber, true)
	s.SetForwardingDefaultAndAllNICs(ipv6.ProtocolNumber, true)
	{
		opt := tcpip.TCPSACKEnabled(true)
		s.SetTransportProtocolOption(tcp.ProtocolNumber, &opt)
	}
	{
		opt := tcpip.DefaultTTLOption(defaultTimeToLive)
		s.SetNetworkProtocolOption(ipv4.ProtocolNumber, &opt)
		s.SetNetworkProtocolOption(ipv6.ProtocolNumber, &opt)
	}
	// We expect no packet loss, therefore we can bump
	// buffers. Too large buffers thrash cache, so there is litle
	// point in too large buffers.
	{
		opt := tcpip.TCPReceiveBufferSizeRangeOption{Min: 1, Default: rcvBufferSize, Max: rcvBufferSize}
		s.SetTransportProtocolOption(tcp.ProtocolNumber, &opt)
	}
	{
		opt := tcpip.TCPSendBufferSizeRangeOption{Min: 1, Default: sndBufferSize, Max: sndBufferSize}
		s.SetTransportProtocolOption(tcp.ProtocolNumber, &opt)
	}

	// Enable Receive Buffer Auto-Tuning, see:
	// https://github.com/google/gvisor/issues/1666
	{
		opt := tcpip.TCPModerateReceiveBufferOption(true)
		s.SetTransportProtocolOption(tcp.ProtocolNumber,
			&opt)
	}

	nicID := tcpip.NICID(s.UniqueID())

	tcpipErr := s.CreateNICWithOptions(nicID, ep, stack.NICOptions{Disabled: false})
	if tcpipErr != nil {
		return nil, fmt.Errorf("CreateNIC: %v", tcpipErr)
	}

	s.SetSpoofing(nicID, true)
	s.SetPromiscuousMode(nicID, true)

	tcpForwarder := tcp.NewForwarder(s, defaultWndSize, maxConnAttempts, func(r *tcp.ForwarderRequest) {
		var (
			wq  waiter.Queue
			ep  tcpip.Endpoint
			err tcpip.Error
			id  = r.ID()
		)
		fmt.Printf("outbound tcp request %s:%d->%s:%d\n",
			id.RemoteAddress, id.RemotePort, id.LocalAddress, id.LocalPort)

		// Perform a TCP three-way handshake.
		ep, err = r.CreateEndpoint(&wq)
		if err != nil {
			// RST: prevent potential half-open TCP connection leak.
			r.Complete(true)

			fmt.Printf("error forwarding tcp request %s:%d->%s:%d, could not create endpoint: %s\n",
				id.RemoteAddress, id.RemotePort, id.LocalAddress, id.LocalPort, err)
			return
		}
		defer r.Complete(false)
		defer func() {
			if err != nil {
				fmt.Printf("error forwarding tcp request %s:%d->%s:%d: %s\n",
					id.RemoteAddress, id.RemotePort, id.LocalAddress, id.LocalPort, err)
			}
		}()

		err = setSocketOptions(s, ep)

		conn := &tcpConn{
			TCPConn: gonet.NewTCPConn(&wq, ep),
			id:      id,
		}
		tcpQueue <- conn
	})

	udpForwarder := udp.NewForwarder(s, func(r *udp.ForwarderRequest) {
		var (
			wq waiter.Queue
			id = r.ID()
		)
		fmt.Printf("forward udp request %s:%d->%s:%d\n",
			id.RemoteAddress, id.RemotePort, id.LocalAddress, id.LocalPort)
		ep, err := r.CreateEndpoint(&wq)
		if err != nil {
			fmt.Printf("error: %s\n", err)
			return
		}
		conn := &udpConn{
			UDPConn: gonet.NewUDPConn(s, &wq, ep),
			id:      id,
		}

		udpQueue <- conn
		// TODO: What goes here?
	})

	s.SetTransportProtocolHandler(tcp.ProtocolNumber, tcpForwarder.HandlePacket)
	s.SetTransportProtocolHandler(udp.ProtocolNumber, udpForwarder.HandlePacket)

	// slirpnetstack method
	// StackRoutingSetup(s, nicID, "10.0.0.8/24")
	// StackRoutingSetup(s, nicID, "fd00::2/64")

	// Tun2socks method
	s.SetRouteTable([]tcpip.Route{{
		Destination: header.IPv4EmptySubnet,
		NIC:         nicID,
	}, {
		Destination: header.IPv6EmptySubnet,
		NIC:         nicID,
	}})

	return s, nil
}

func StackRoutingSetup(s *stack.Stack, nic tcpip.NICID, assignNet string) {
	ipAddr, ipNet, err := net.ParseCIDR(assignNet)
	if err != nil {
		panic(fmt.Sprintf("Unable to ParseCIDR(%s): %s", assignNet, err))
	}

	if ipAddr.To4() != nil {
		s.AddProtocolAddress(1, tcpip.ProtocolAddress{
			Protocol:          ipv4.ProtocolNumber,
			AddressWithPrefix: tcpip.Address(ipAddr.To4()).WithPrefix(),
		}, stack.AddressProperties{})
	} else {
		s.AddProtocolAddress(1, tcpip.ProtocolAddress{
			Protocol:          ipv6.ProtocolNumber,
			AddressWithPrefix: tcpip.Address(ipAddr).WithPrefix(),
		}, stack.AddressProperties{})
	}

	rt := s.GetRouteTable()
	rt = append(rt, tcpip.Route{
		Destination: *MustSubnet(ipNet),
		NIC:         nic,
	})
	s.SetRouteTable(rt)
}

func MustSubnet(ipNet *net.IPNet) *tcpip.Subnet {
	subnet, errx := tcpip.NewSubnet(tcpip.Address(ipNet.IP), tcpip.AddressMask(ipNet.Mask))
	if errx != nil {
		panic(fmt.Sprintf("Unable to MustSubnet(%s): %s", ipNet, errx))
	}
	return &subnet
}

func setSocketOptions(s *stack.Stack, ep tcpip.Endpoint) tcpip.Error {
	{ /* TCP keepalive options */
		ep.SocketOptions().SetKeepAlive(true)

		idle := tcpip.KeepaliveIdleOption(tcpKeepaliveIdle)
		if err := ep.SetSockOpt(&idle); err != nil {
			return err
		}

		interval := tcpip.KeepaliveIntervalOption(tcpKeepaliveInterval)
		if err := ep.SetSockOpt(&interval); err != nil {
			return err
		}

		if err := ep.SetSockOptInt(tcpip.KeepaliveCountOption, tcpKeepaliveCount); err != nil {
			return err
		}
	}
	{ /* TCP recv/send buffer size */
		var ss tcpip.TCPSendBufferSizeRangeOption
		if err := s.TransportProtocolOption(header.TCPProtocolNumber, &ss); err == nil {
			ep.SocketOptions().SetReceiveBufferSize(int64(ss.Default), false)
		}

		var rs tcpip.TCPReceiveBufferSizeRangeOption
		if err := s.TransportProtocolOption(header.TCPProtocolNumber, &rs); err == nil {
			ep.SocketOptions().SetReceiveBufferSize(int64(rs.Default), false)
		}
	}
	return nil
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	ep := channel.New(10, defaultMTU, "10.0.0.8")
	tcpQueue := make(chan adapter.TCPConn)
	udpQueue := make(chan adapter.UDPConn)

	// With high mtu, low packet loss and low latency over tuntap,
	// the specific value isn't that important. The only important
	// bit is that it should be at least a couple times MSS.
	bufSize := 4 * 1024 * 1024

	s, err := createStack(ep, tcpQueue, udpQueue, bufSize, bufSize)
	if err != nil {
		log.Panicln(err)
	}

	cConn, err := net.ListenUDP("udp", &net.UDPAddr{IP: netip.MustParseAddr("0.0.0.0").AsSlice(), Port: 8080})
	if err != nil {
		log.Fatalf("Udp Service listen report udp fail:%v", err)
	}
	defer cConn.Close()
	log.Printf("Listening on port %s", port)

	server := Server{
		cConn:    cConn,
		stack:    s,
		ep:       ep,
		tcpQueue: tcpQueue,
		udpQueue: udpQueue,
	}
	server.InitOutboundHandlers()
	server.Listen()
}
