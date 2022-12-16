package controller

import (
	"math"
	"time"
)

var latencyPerByteMax time.Duration = 0

type ProportionalSlowable struct {
	*SlowableBase
	c    ControllerSettingsReadonly
	gain float64
}

func InitProportionalSlowable(c ControllerSettingsReadonly) *ProportionalSlowable {
	initialLatencyPerByte := time.Duration(0)
	if !math.IsInf(c.RxSpeedTarget(), 1) {
		initialLatencyPerByte = 18 * time.Microsecond * 400000.0 / time.Duration(c.RxSpeedTarget())
	}
	// log.Printf("initial latency per byte: %s", initialLatencyPerByte)
	ret := &ProportionalSlowable{
		SlowableBase: InitSlowableBase(initialLatencyPerByte),
		c:            c,
		gain:         1000,
	}
	ret.Sampler = ret
	return ret
}

func (s *ProportionalSlowable) Sample(n int, dt time.Duration) {
	// Update rxSpeed
	s.SlowableBase.Sample(n, dt)

	// Update settings
	if math.IsInf(s.c.RxSpeedTarget(), 1) {
		// no need to update latencyPerByte
		return
	}

	e := (s.c.RxSpeedTarget() - s.RxSpeed()) / s.c.RxSpeedTarget() // proportional error
	update := -1.0 * time.Duration(e*s.gain)
	oldLatencyPerByte := s.RxLatencyPerByte()
	newLatencyPerByte := oldLatencyPerByte + update
	if newLatencyPerByte < 0 {
		newLatencyPerByte = 0
	}
	_ = time.Duration(n) * newLatencyPerByte
	// log.Printf("dRx: %d, e: %.2f, rxSpeed: %.0f, newLatencyPerByte: %s, nextLatency: %s", s.dRx, e, s.RxSpeed(), newLatencyPerByte, nextLatency)
	if newLatencyPerByte > latencyPerByteMax {
		latencyPerByteMax = newLatencyPerByte
		// log.Printf("new latency max: %s", latencyMax)
	}
	s.SetRxLatencyPerByte(newLatencyPerByte)
}
