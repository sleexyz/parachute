package tunconn

import (
	"fmt"
	"net"
	"net/netip"
)

// NOTE: only supports a single client
type UDPServerConn struct {
	conn    *net.UDPConn
	udpAddr *net.UDPAddr
}

func InitUDPServerConn(port int) (*UDPServerConn, error) {
	conn, err := net.ListenUDP("udp", &net.UDPAddr{IP: netip.MustParseAddr("0.0.0.0").AsSlice(), Port: port})
	if err != nil {
		return nil, err
	}
	return &UDPServerConn{
		conn: conn,
	}, nil
}

func (i *UDPServerConn) Close() {
	i.conn.Close()
}

func (i *UDPServerConn) Read(b []byte) (int, error) {
	n, addr, err := i.conn.ReadFromUDP(b)
	if addr != nil {
		i.udpAddr = addr
	}
	return n, err
}

func (i *UDPServerConn) Write(b []byte) (int, error) {
	if i.udpAddr == nil {
		return 0, fmt.Errorf("error: downstream UDP connection not initialized")
	}
	return i.conn.WriteTo(b, i.udpAddr)
}
