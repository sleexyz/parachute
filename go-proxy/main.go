package main

import (
	"fmt"
	"log"
	"net"
	"time"
	"errors"
	"context"

	"os"

	M "strange.industries/go-proxy/metadata"
	"strange.industries/go-proxy/forwarder"
	"strange.industries/go-proxy/adapter"
	"golang.zx2c4.com/go118/netip"

	"gvisor.dev/gvisor/pkg/tcpip"
	"gvisor.dev/gvisor/pkg/tcpip/adapters/gonet"
	"gvisor.dev/gvisor/pkg/tcpip/buffer"
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

type Deps struct {
	tcpQueue chan adapter.TCPConn
	udpQueue chan adapter.UDPConn
	ep       *channel.Endpoint
}

type Server struct {
	conn  *net.UDPConn
	stack *stack.Stack
	deps  *Deps
}

type Proxy struct {
	addr string
	dialer *net.Dialer
}

func (b *Proxy) DialContext(ctx context.Context, metadata *M.Metadata) (net.Conn, error) {
	c, err := b.dialer.DialContext(ctx, "tcp", metadata.DestinationAddress())
	if err != nil {
		return nil, err
	}
	setKeepAlive(c)
	return c, nil
}

const (
	tcpKeepAlivePeriod = 30 * time.Second
)

// setKeepAlive sets tcp keepalive option for tcp connection.
func setKeepAlive(c net.Conn) {
	if tcp, ok := c.(*net.TCPConn); ok {
		tcp.SetKeepAlive(true)
		tcp.SetKeepAlivePeriod(tcpKeepAlivePeriod)
	}
}


func (b *Proxy) DialUDP(*M.Metadata) (net.PacketConn, error) {
	return nil, errors.New("not supported")
}

type tcpConn struct {
	*gonet.TCPConn
	id stack.TransportEndpointID
}

func (c *tcpConn) ID() *stack.TransportEndpointID {
	return &c.id
}


func (c *Server) Init() {
	go func () {
		for {
			select {
			case conn := <- c.deps.tcpQueue:
				go forwarder.HandleTCPConn(conn)
			case conn := <- c.deps.udpQueue:
				go forwarder.HandleUDPConn(conn)
			}
		}
	}()
}

func (c *Server) Write(buf []byte, offset int) (int, error) {
	packet := buf[offset:]
	if len(packet) == 0 {
		return 0, nil
	}
	pkb := stack.NewPacketBuffer(stack.PacketBufferOptions{Data: buffer.NewVectorisedView(len(packet), []buffer.View{buffer.NewViewFromBytes(packet)})})
	// c.deps.ep.WriteRawPacket(pkb)
	switch packet[0] >> 4 {
	case 4:
		c.deps.ep.InjectInbound(ipv4.ProtocolNumber, pkb)
	case 6:
		c.deps.ep.InjectInbound(ipv6.ProtocolNumber, pkb)
	}
	return len(buf), nil
}

func (c *Server) Listen() {
	for {
		data := make([]byte, 1024*4)
		n, _, err := c.conn.ReadFromUDP(data)
		if err == nil {
			// sEnc := b64.StdEncoding.EncodeToString([]byte(data[:n]))
			// fmt.Println(sEnc)

			// ipVersion := (data[0] & 0xf0) >> 4
			// var packet gopacket.Packet
			// if ipVersion == 6 {
			// 	packet = gopacket.NewPacket(data[:n], layers.LayerTypeIPv6, gopacket.Default)
			// } else {
			// 	packet = gopacket.NewPacket(data[:n], layers.LayerTypeIPv4, gopacket.Default)
			// }
			// if ipv4Layer := packet.Layer(layers.LayerTypeIPv4); ipv4Layer != nil {
			// 	fmt.Println("This is a ipv4 packet!")
			// 	ipv4, _ := ipv4Layer.(*layers.IPv4)
			// 	fmt.Printf("From src address %d to dst address %d\n", ipv4.SrcIP, ipv4.DstIP)
			// }
			// if ipv6Layer := packet.Layer(layers.LayerTypeIPv6); ipv6Layer != nil {
			// 	fmt.Println("This is a ipv6 packet!")
			// 	ipv6, _ := ipv6Layer.(*layers.IPv6)
			// 	fmt.Printf("From src address %d to dst address %d\n", ipv6.SrcIP, ipv6.DstIP)
			// }
			// if tcpLayer := packet.Layer(layers.LayerTypeTCP); tcpLayer != nil {
			// 	fmt.Println("This is a TCP packet!")
			// 	// Get actual TCP data from this layer
			// 	tcp, _ := tcpLayer.(*layers.TCP)
			// 	fmt.Printf("From src port %d to dst port %d\n", tcp.SrcPort, tcp.DstPort)
			// }
			// Iterate over all layers, printing out each layer type
			// for _, layer := range packet.Layers() {
			// 	fmt.Println("PACKET LAYER:", layer.LayerType())
			// }
			_, err := c.Write(data[:n], 0)
			if err != nil {
				fmt.Printf("bad write: %s\n", err)
			} else {
				// fmt.Printf("bytes written: %d\n", n)
			}
		}
	}
}

const (
	defaultMTU = 1500

	// defaultWndSize if set to zero, the default
	// receive window buffer size is used instead.
	defaultWndSize = 0

	// maxConnAttempts specifies the maximum number
	// of in-flight tcp connection attempts.
	maxConnAttempts = 10
	// maxConnAttempts = 2 << 10

	// tcpKeepaliveCount is the maximum number of
	// TCP keep-alive probes to send before giving up
	// and killing the connection if no response is
	// obtained from the other end.
	tcpKeepaliveCount = 9

	// tcpKeepaliveIdle specifies the time a connection
	// must remain idle before the first TCP keepalive
	// packet is sent. Once this time is reached,
	// tcpKeepaliveInterval option is used instead.
	tcpKeepaliveIdle = 60 * time.Second

	// tcpKeepaliveInterval specifies the interval
	// time between sending TCP keepalive packets.
	tcpKeepaliveInterval = 30 * time.Second
)

func createStack(deps *Deps, rcvBufferSize int, sndBufferSize int) (*stack.Stack, error) {
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
		opt := tcpip.DefaultTTLOption(64)
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

	tcpipErr := s.CreateNICWithOptions(1, deps.ep, stack.NICOptions{Disabled: false})
	if tcpipErr != nil {
		return nil, fmt.Errorf("CreateNIC: %v", tcpipErr)
	}

	s.SetSpoofing(1, true)
	s.SetPromiscuousMode(1, true)

	tcpForwarder := tcp.NewForwarder(s, defaultWndSize, maxConnAttempts, func(r *tcp.ForwarderRequest) {
		var (
			wq  waiter.Queue
			ep  tcpip.Endpoint
			err tcpip.Error
			id  = r.ID()
		)
		// TODO: why doesn't this log?
		fmt.Printf("forward tcp request %s:%d->%s:%d\n",
			id.RemoteAddress, id.RemotePort, id.LocalAddress, id.LocalPort)

		defer func() {
			if err != nil {
				fmt.Printf("error: %s\n", err)
			}
		}()

		// Perform a TCP three-way handshake.
		ep, err = r.CreateEndpoint(&wq)
		if err != nil {
			// RST: prevent potential half-open TCP connection leak.
			r.Complete(true)
			return
		}
		defer r.Complete(false)

		err = setSocketOptions(s, ep)

		conn := &tcpConn{
			TCPConn: gonet.NewTCPConn(&wq, ep),
			id:      id,
		}
		deps.tcpQueue <- conn
		// TODO: What goes here?
	})

	udpForwarder := udp.NewForwarder(s, func(r *udp.ForwarderRequest) {
		var (
			wq waiter.Queue
			id = r.ID()
		)
		fmt.Printf("udp forwarder request %s:%d->%s:%d\n",
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

		deps.udpQueue <- conn
		// TODO: What goes here?
	})

	s.SetTransportProtocolHandler(tcp.ProtocolNumber, tcpForwarder.HandlePacket)
	s.SetTransportProtocolHandler(udp.ProtocolNumber, udpForwarder.HandlePacket)

	StackRoutingSetup(s, 1, "10.0.0.8/24")
	StackRoutingSetup(s, 1, "fd00::2/64")

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

type udpConn struct {
	*gonet.UDPConn
	id stack.TransportEndpointID
}

func (c *udpConn) ID() *stack.TransportEndpointID {
	return &c.id
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
	// ep.LinkEPCapabilities = stack.CapabilityLoopback
	// fmt.Println(ep.LinkEPCapabilities)
	// ep := loopback.New()

	deps := &Deps{
		ep:       ep,
		tcpQueue: make(chan adapter.TCPConn), // TODO: unused
		udpQueue: make(chan adapter.UDPConn), // TODO: unused
	}

	// With high mtu, low packet loss and low latency over tuntap,
	// the specific value isn't that important. The only important
	// bit is that it should be at least a couple times MSS.
	bufSize := 4 * 1024 * 1024

	s, err := createStack(deps, bufSize, bufSize)
	if err != nil {
		log.Panicln(err)
	}

	conn, err := net.ListenUDP("udp", &net.UDPAddr{IP: netip.MustParseAddr("0.0.0.0").AsSlice(), Port: 8080})
	if err != nil {
		log.Fatalf("Udp Service listen report udp fail:%v", err)
	}
	defer conn.Close()

	log.Printf("Listening on port %s", port)

	server := Server{conn: conn, stack: s, deps: deps}
	server.Init()
	server.Listen()
}
