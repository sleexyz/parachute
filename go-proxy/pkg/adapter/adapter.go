package adapter

import (
	"net"

	"gvisor.dev/gvisor/pkg/tcpip/stack"
	"strange.industries/go-proxy/pkg/controller"
	"strange.industries/go-proxy/pkg/controller/flow"
)

// UDPConn implements net.Conn and net.PacketConn.
type UDPConn interface {
	net.Conn
	net.PacketConn
	flow.Flow
	Controller() *controller.Controller
	// ID returns the transport endpoint id of UDPConn.
	ID() *stack.TransportEndpointID
}

// TCPConn implements the net.Conn interface.
type TCPConn interface {
	net.Conn
	flow.Flow
	Controller() *controller.Controller
	// ID returns the transport endpoint id of TCPConn.
	ID() *stack.TransportEndpointID
}
