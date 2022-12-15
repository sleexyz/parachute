package router

import (
	"fmt"
	"net"
	"time"

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
	"strange.industries/go-proxy/pkg/adapter"
	"strange.industries/go-proxy/pkg/controller"
	"strange.industries/go-proxy/pkg/logger"
)

type tcpConn struct {
	*gonet.TCPConn
	slowable controller.Slowable
	id       stack.TransportEndpointID
}

func (c *tcpConn) Slowable() controller.Slowable {
	return c.slowable
}

func (c *tcpConn) ID() *stack.TransportEndpointID {
	return &c.id
}

type udpConn struct {
	*gonet.UDPConn
	slowable controller.Slowable
	id       stack.TransportEndpointID
}

func (c *udpConn) Slowable() controller.Slowable {
	return c.slowable
}

func (c *udpConn) ID() *stack.TransportEndpointID {
	return &c.id
}

const (
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
	// tcpKeepaliveIdle = 60 * time.Second
	tcpKeepaliveIdle = 60 * time.Second

	// tcpKeepaliveInterval specifies the interval
	// time between sending TCP keepalive packets.
	tcpKeepaliveInterval = 30 * time.Second

	// defaultTimeToLive specifies the default TTL used by stack.
	defaultTimeToLive uint8 = 64

	rcvBufferSize = 16 >> 10
	sndBufferSize = 16 >> 10
)

func createStack(ep *channel.Endpoint, tcpQueue chan adapter.TCPConn, udpQueue chan adapter.UDPConn, c *controller.Controller) (*stack.Stack, error) {
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

	// NOTE: Disabled for memory optimization, see:
	// https://github.com/xjasonlyu/tun2socks/wiki/Memory-Optimization
	// Enable Receive Buffer Auto-Tuning, see:
	// https://github.com/google/gvisor/issues/1666
	// {
	// 	opt := tcpip.TCPModerateReceiveBufferOption(true)
	// 	s.SetTransportProtocolOption(tcp.ProtocolNumber,
	// 		&opt)
	// }

	nicID := tcpip.NICID(s.UniqueID())

	tcpipErr := s.CreateNICWithOptions(nicID, ep, stack.NICOptions{Name: "userTUN", Disabled: false})
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
		// Perform a TCP three-way handshake.
		ep, err = r.CreateEndpoint(&wq)
		if err != nil {
			// RST: prevent potential half-open TCP connection leak.
			r.Complete(true)

			logger.Logger.Printf("error forwarding tcp request %s:%d->%s:%d, could not create endpoint: %s\n",
				id.RemoteAddress, id.RemotePort, id.LocalAddress, id.LocalPort, err)
			return
		}
		defer r.Complete(false)
		defer func() {
			if err != nil {
				logger.Logger.Printf("error forwarding tcp request %s:%d->%s:%d: %s\n",
					id.RemoteAddress, id.RemotePort, id.LocalAddress, id.LocalPort, err)
			}
		}()

		err = setSocketOptions(s, ep)

		conn := &tcpConn{
			TCPConn:  gonet.NewTCPConn(&wq, ep),
			id:       id,
			slowable: controller.InitProportionalSlowable(c),
		}
		tcpQueue <- conn
	})

	udpForwarder := udp.NewForwarder(s, func(r *udp.ForwarderRequest) {
		var (
			wq waiter.Queue
			id = r.ID()
		)
		ep, err := r.CreateEndpoint(&wq)
		if err != nil {
			fmt.Printf("error: %s\n", err)
			return
		}
		conn := &udpConn{
			UDPConn:  gonet.NewUDPConn(s, &wq, ep),
			id:       id,
			slowable: controller.InitProportionalSlowable(c),
		}
		udpQueue <- conn
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

func stackRoutingSetup(s *stack.Stack, nic tcpip.NICID, assignNet string) {
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
		Destination: *mustSubnet(ipNet),
		NIC:         nic,
	})
	s.SetRouteTable(rt)
}

func mustSubnet(ipNet *net.IPNet) *tcpip.Subnet {
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
