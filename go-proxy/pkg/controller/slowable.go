package controller

import (
	"net"
	"time"

	"strange.industries/go-proxy/pkg/logger"
)

type SlowableConn struct {
	net.Conn
	S Slowable
}

func (r *SlowableConn) Read(p []byte) (n int, err error) {
	n, err = r.Conn.Read(p)
	r.S.RecordBytesRead(n)
	r.S.InjectRxLatency()
	return
}

// TODO: see if I can deprecate this for slowableconn
type SlowablePacketConn struct {
	net.PacketConn
	S Slowable
}

func (r *SlowablePacketConn) ReadFrom(p []byte) (n int, addr net.Addr, err error) {
	n, addr, err = r.PacketConn.ReadFrom(p)
	r.S.RecordBytesRead(n)
	r.S.InjectRxLatency()
	return
}

type Flow interface {
	Slowable
}

type Slowable interface {
	RecordBytesRead(n int)
	InjectRxLatency()
}

type SlowableBase struct {
	rxSpeed        float64
	lastSampleTime time.Time
	rxLatency      time.Duration
}

func (s *SlowableBase) InjectRxLatency() {
	if s.rxLatency == 0 {
		return
	}
	logger.Logger.Printf("sleeping %s", s.rxLatency)
	time.Sleep(s.rxLatency)
}

func InitSlowableBase(initialLatency time.Duration) *SlowableBase {
	return &SlowableBase{
		rxSpeed:        0,
		lastSampleTime: time.Now(),
		rxLatency:      initialLatency,
	}
}

func (s *SlowableBase) SetRxLatency(l time.Duration) {
	s.rxLatency = l
}

func (s *SlowableBase) RecordBytesRead(n int) {
	now := time.Now()
	dt := now.Sub(s.lastSampleTime)
	// bytes/nanoseconds * 10^9 nanoseconds/second * 8 bits/byte
	s.rxSpeed = float64(n) / float64(dt) * float64(time.Second) * 8
	s.lastSampleTime = now
}

func (s *SlowableBase) RxSpeed() float64 {
	return s.rxSpeed
}

func (s *SlowableBase) RxLatency() time.Duration {
	return s.rxLatency
}
