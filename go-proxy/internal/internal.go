package internal

import (
	"fmt"
	"net"
	"net/netip"
)

type Internal interface {
	Write(b []byte) (int, error)
	Read(b []byte) (int, error)
}

type DirectInternal struct {
	conn    *net.UDPConn
	udpAddr *net.UDPAddr
}

func InitDirectInternal(port int) (*DirectInternal, error) {
	conn, err := net.ListenUDP("udp", &net.UDPAddr{IP: netip.MustParseAddr("0.0.0.0").AsSlice(), Port: port})
	if err != nil {
		return nil, err
	}
	return &DirectInternal{
		conn: conn,
	}, nil
}

func (d *DirectInternal) Close() {
	d.conn.Close()
}

func (d *DirectInternal) Read(b []byte) (int, error) {
	n, addr, err := d.conn.ReadFromUDP(b)
	if addr != nil {
		d.udpAddr = addr
	}
	return n, err
}

func (d *DirectInternal) Write(b []byte) (int, error) {
	if d.udpAddr == nil {
		return 0, fmt.Errorf("Error: downstream UDP connection not initialized.")
	}
	return d.conn.WriteTo(b, d.udpAddr)
}
