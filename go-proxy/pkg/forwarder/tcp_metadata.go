package forwarder

import (
	"net"
	"strconv"
)

// Metadata contains metadata of transport protocol sessions.
type metadata struct {
	SrcIP   net.IP
	MidIP   net.IP
	DstIP   net.IP
	SrcPort uint16
	MidPort uint16
	DstPort uint16
}

func (m *metadata) DestinationAddress() string {
	return net.JoinHostPort(m.DstIP.String(), strconv.FormatUint(uint64(m.DstPort), 10))
}

func (m *metadata) SourceAddress() string {
	return net.JoinHostPort(m.SrcIP.String(), strconv.FormatUint(uint64(m.SrcPort), 10))
}

func (m *metadata) TCPAddr() *net.TCPAddr {
	return &net.TCPAddr{
		IP:   m.DstIP,
		Port: int(m.DstPort),
	}
}
