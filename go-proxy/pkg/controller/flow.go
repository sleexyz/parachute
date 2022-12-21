package controller

import (
	"time"
)

type Flow interface {
	Controller() *Controller
	Update(n int, now time.Time)
	InjectRxLatency(n int)
	DecRef()
	IncRef()
}

type FlowBase struct {
	// total rxBytes
	rxBytes int64
	// rxBytes since last sample time
	dRx            int
	lastSampleTime *time.Time
	rxSpeed        float64

	rxLatencyPerByte time.Duration
	Updater          Updater
}

type Updater interface {
	UpdateFn(n int, now time.Time, dt time.Duration)
}

func (s *FlowBase) InjectRxLatency(n int) {
	if s.rxLatencyPerByte <= 0 {
		return
	}
	time.Sleep(s.rxLatencyPerByte * time.Duration(n))
}

func InitFlowBase() *FlowBase {
	now := time.Now()
	ret := &FlowBase{
		rxSpeed:          0,
		lastSampleTime:   &now,
		rxLatencyPerByte: 0,
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
		s.Updater.UpdateFn(s.dRx, now, dt)
		s.lastSampleTime = &now
		s.dRx = 0
	}
}

func (s *FlowBase) UpdateFn(n int, now time.Time, dt time.Duration) {
	s.rxSpeed = float64(s.dRx) / float64(dt) * float64(time.Second) * 8
}

func (s *FlowBase) RxSpeed() float64 {
	return s.rxSpeed
}

func (s *FlowBase) RxLatencyPerByte() time.Duration {
	return s.rxLatencyPerByte
}
