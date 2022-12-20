package controller

import (
	"net"
	"time"
)

type FlowConn struct {
	net.Conn
	S Flow
}

func (r *FlowConn) Read(p []byte) (n int, err error) {
	n, err = r.Conn.Read(p)
	r.S.Update(n, time.Now())
	r.S.InjectRxLatency(n)
	return
}

type FlowPacketConn struct {
	net.PacketConn
	S Flow
}

func (r *FlowPacketConn) ReadFrom(p []byte) (n int, addr net.Addr, err error) {
	n, addr, err = r.PacketConn.ReadFrom(p)
	r.S.Update(n, time.Now())
	r.S.InjectRxLatency(n)
	return
}
