package controller

import (
	"math"
	"time"

	"strange.industries/go-proxy/pkg/logger"
)

type ProportionalSlowable struct {
	*SlowableBase
	c    ControllerSettingsReadonly
	gain float64
}

func InitProportionalSlowable(c ControllerSettingsReadonly) *ProportionalSlowable {
	initialLatency := 500 * time.Millisecond
	if math.IsInf(c.RxSpeedTarget(), 1) {
		initialLatency = 0
	}
	return &ProportionalSlowable{
		SlowableBase: InitSlowableBase(initialLatency),
		c:            c,
		gain:         4000 / 8,
	}
}

func (s *ProportionalSlowable) InjectRxLatency() {
	if math.IsInf(s.c.RxSpeedTarget(), 1) {
		// s.SetRxLatency(0)
		return
	}
	e := s.c.RxSpeedTarget() - s.RxSpeed()
	update := -1.0 * time.Duration(e*s.gain)
	oldLatency := s.RxLatency()
	newLatency := oldLatency + update
	if newLatency < 0 {
		newLatency = 0
	}

	logger.Logger.Printf("rxSpeedTarget: %f, newLatency: %s", s.c.RxSpeedTarget(), newLatency)
	s.SetRxLatency(newLatency)
	s.SlowableBase.InjectRxLatency()
}
