package controller

import (
	"net"
	"time"
)

type SlowableConn struct {
	net.Conn
	S Slowable
}

func (r *SlowableConn) Read(p []byte) (n int, err error) {
	n, err = r.Conn.Read(p)
	r.S.Update(n, time.Now())
	r.S.InjectRxLatency(n)
	return
}

// TODO: see if I can deprecate this for slowableconn
type SlowablePacketConn struct {
	net.PacketConn
	S Slowable
}

func (r *SlowablePacketConn) ReadFrom(p []byte) (n int, addr net.Addr, err error) {
	n, addr, err = r.PacketConn.ReadFrom(p)
	r.S.Update(n, time.Now())
	r.S.InjectRxLatency(n)
	return
}

type Slowable interface {
	Update(n int, now time.Time)
	InjectRxLatency(n int)
}

type SlowableBase struct {
	// total rxBytes
	rxBytes int64
	// rxBytes since last sample time
	dRx            int
	lastSampleTime *time.Time
	rxSpeed        float64

	rxLatencyPerByte time.Duration
	SamplePublisher  SamplePublisher
	Sampler          Sampler
}

type SamplePublisher interface {
	PublishSample(n int, now time.Time, dt time.Duration)
}

type Sampler interface {
	Sample(n int, dt time.Duration)
}

func (s *SlowableBase) InjectRxLatency(n int) {
	if s.rxLatencyPerByte <= 0 {
		return
	}
	time.Sleep(s.rxLatencyPerByte * time.Duration(n))
}

func InitSlowableBase(initialLatencyPerByte time.Duration) *SlowableBase {
	now := time.Now()
	self := &SlowableBase{
		rxSpeed:          0,
		lastSampleTime:   &now,
		rxLatencyPerByte: initialLatencyPerByte,
	}
	self.Sampler = self
	return self
}

func (s *SlowableBase) SetRxLatencyPerByte(l time.Duration) {
	s.rxLatencyPerByte = l
}

func (s *SlowableBase) Update(n int, now time.Time) {
	s.rxBytes += int64(n)
	s.dRx += n
	dt := now.Sub(*s.lastSampleTime)
	if dt > time.Second {
		s.Sampler.Sample(s.dRx, dt)
		if s.SamplePublisher != nil {
			s.SamplePublisher.PublishSample(s.dRx, now, dt)
		}
		s.lastSampleTime = &now
		s.dRx = 0
	}
}

func (s *SlowableBase) Sample(n int, dt time.Duration) {
	s.rxSpeed = float64(s.dRx) / float64(dt) * float64(time.Second) * 8
}

func (s *SlowableBase) RxSpeed() float64 {
	return s.rxSpeed
}

func (s *SlowableBase) RxLatencyPerByte() time.Duration {
	return s.rxLatencyPerByte
}
