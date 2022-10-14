package internal

import (
	"fmt"
	"net"
	"net/netip"
)

type UDPIConn struct {
	conn    *net.UDPConn
	udpAddr *net.UDPAddr
}

func InitUDPIConn(port int) (*UDPIConn, error) {
	conn, err := net.ListenUDP("udp", &net.UDPAddr{IP: netip.MustParseAddr("0.0.0.0").AsSlice(), Port: port})
	if err != nil {
		return nil, err
	}
	return &UDPIConn{
		conn: conn,
	}, nil
}

func (i *UDPIConn) Close() {
	i.conn.Close()
}

func (i *UDPIConn) Read(b []byte) (int, error) {
	n, addr, err := i.conn.ReadFromUDP(b)
	if addr != nil {
		i.udpAddr = addr
	}
	return n, err
}

func (i *UDPIConn) Write(b []byte) (int, error) {
	if i.udpAddr == nil {
		return 0, fmt.Errorf("error: downstream UDP connection not initialized")
	}
	return i.conn.WriteTo(b, i.udpAddr)
}
