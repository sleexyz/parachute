package controller

import (
	"time"

	"strange.industries/go-proxy/pkg/analytics"
)

type Flow interface {
	Update(n int, now time.Time)
	InjectRxLatency(n int)
}

type FlowBase struct {
	ip string
	// total rxBytes
	rxBytes int64
	// rxBytes since last sample time
	dRx            int
	lastSampleTime *time.Time
	rxSpeed        float64

	rxLatencyPerByte time.Duration
	SamplePublisher  analytics.SamplePublisher
	Updater          Updater
}

type Updater interface {
	UpdateFn(n int, dt time.Duration)
}

func (s *FlowBase) InjectRxLatency(n int) {
	if s.rxLatencyPerByte <= 0 {
		return
	}
	time.Sleep(s.rxLatencyPerByte * time.Duration(n))
}

func InitFlowBase(initialLatencyPerByte time.Duration, ip string, sp analytics.SamplePublisher) *FlowBase {
	now := time.Now()
	ret := &FlowBase{
		ip:               ip,
		rxSpeed:          0,
		lastSampleTime:   &now,
		rxLatencyPerByte: initialLatencyPerByte,
		SamplePublisher:  sp,
	}
	ret.Updater = ret
	return ret
}

func (s *FlowBase) SetRxLatencyPerByte(l time.Duration) {
	s.rxLatencyPerByte = l
}

func (s *FlowBase) Update(n int, now time.Time) {
	s.rxBytes += int64(n)
	s.dRx += n
	dt := now.Sub(*s.lastSampleTime)
	if dt > time.Second {
		s.Updater.UpdateFn(s.dRx, dt)
		go s.SamplePublisher.PublishSample(s.ip, s.dRx, now, dt)
		s.lastSampleTime = &now
		s.dRx = 0
	}
}

func (s *FlowBase) UpdateFn(n int, dt time.Duration) {
	s.rxSpeed = float64(s.dRx) / float64(dt) * float64(time.Second) * 8
}

func (s *FlowBase) RxSpeed() float64 {
	return s.rxSpeed
}

func (s *FlowBase) RxLatencyPerByte() time.Duration {
	return s.rxLatencyPerByte
}
