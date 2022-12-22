package controller

import (
	"math"
	"time"

	"strange.industries/go-proxy/pkg/analytics"
)

type SpeedControlledFlow struct {
	*LatencyControlledFlow
	gain          float64
	speedProvider SpeedProvider
}

type SpeedProvider interface {
	InitialSpeed() float64
	UpdateSpeed(ctx *UpdateCtx) float64
}

func InitSpeedControlledFlow(samplePublisher analytics.SamplePublisher, speedProvider SpeedProvider) *SpeedControlledFlow {
	// log.Printf("initial latency per byte: %s", initialLatencyPerByte)
	f := &SpeedControlledFlow{
		gain:          1000,
		speedProvider: speedProvider,
	}
	f.LatencyControlledFlow = InitLatencyControlledFlow(f, samplePublisher)
	return f
}

func (f *SpeedControlledFlow) InitialLatency() time.Duration {
	st := f.speedProvider.InitialSpeed()
	return 18 * time.Microsecond * 400000.0 / time.Duration(st)
}

func (f *SpeedControlledFlow) UpdateLatency(ctx *UpdateCtx, n int, now time.Time, dt time.Duration, latencyPerByte time.Duration, rxSpeed float64) time.Duration {
	st := f.speedProvider.UpdateSpeed(ctx)
	if math.IsInf(st, 1) {
		return 0
	}
	e := (st - rxSpeed) / st // proportional error
	update := -1.0 * time.Duration(e*f.gain)
	newLatencyPerByte := latencyPerByte + update
	if newLatencyPerByte < 0 {
		newLatencyPerByte = 0
	}
	return newLatencyPerByte
}
