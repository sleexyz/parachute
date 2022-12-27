package controller

import (
	"log"
	"math"
	"time"

	"google.golang.org/protobuf/types/known/timestamppb"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
)

type LatencyControlledFlow struct {
	// rxBytes since last sample time
	dRx int
	// txBytes since last sample time
	dTx            int
	lastSampleTime *time.Time
	rxSpeed        float64
	refCount       int

	rxLatencyPerByte time.Duration
	latencyProvider  LatencyProvider
	sp               analytics.SamplePublisher
	updateTxProvider UpdateTxProvider
}

type UpdateTxProvider interface {
	UpdateTx(n int, now time.Time)
}

type LatencyProvider interface {
	InitialLatency() time.Duration
	UpdateLatency(ctx *UpdateRxCtx, n int, now time.Time, dt time.Duration, latencyPerByte time.Duration, rxSpeed float64) time.Duration
}

func (s *LatencyControlledFlow) InjectRxLatency(n int) {
	if s.rxLatencyPerByte <= 0 {
		return
	}
	time.Sleep(s.rxLatencyPerByte * time.Duration(n))
}

// NOTE: initializes refCount to 0
func InitLatencyControlledFlow(latencyProvider LatencyProvider, sp analytics.SamplePublisher) *LatencyControlledFlow {
	now := time.Now()
	ret := &LatencyControlledFlow{
		refCount:         0,
		rxSpeed:          0,
		lastSampleTime:   &now,
		rxLatencyPerByte: latencyProvider.InitialLatency(),
		latencyProvider:  latencyProvider,
		sp:               sp,
	}
	return ret
}

func (s *LatencyControlledFlow) RecordTxBytes(n int, now time.Time) {
	s.dTx += n
	if s.updateTxProvider != nil {
		s.updateTxProvider.UpdateTx(n, now)
	}
}

type UpdateRxCtx struct {
	sample  *proxyservice.Sample
	now     *time.Time
	rxBytes int
	rxSpeed float64
}

func (s *LatencyControlledFlow) RecordRxBytes(n int, now time.Time) {
	s.dRx += n
	dt := now.Sub(*s.lastSampleTime)
	// update ever quarter second
	if dt > time.Second/4 {
		s.rxSpeed = float64(s.dRx) / float64(dt) * float64(time.Second) * 8

		sample := &proxyservice.Sample{}
		sample.RxBytes = int64(s.dRx)
		sample.StartTime = timestamppb.New(now)
		sample.Duration = int64(dt)
		sample.RxSpeed = s.rxSpeed

		updateCtx := &UpdateRxCtx{sample: sample, now: &now, rxBytes: s.dRx, rxSpeed: s.rxSpeed}
		s.rxLatencyPerByte = s.latencyProvider.UpdateLatency(updateCtx, s.dRx, now, dt, s.rxLatencyPerByte, s.rxSpeed)
		go s.publishSample(sample)
		s.lastSampleTime = &now
		s.dRx = 0
	}
}

func (s *LatencyControlledFlow) publishSample(sample *proxyservice.Sample) {
	if math.IsInf(sample.RxSpeedTarget, 1) {
		log.Printf("(Skipped): %v", sample)
	}
	go s.sp.PublishSample(sample)
}

func (f *LatencyControlledFlow) IncRef() {
	f.refCount += 1
}

func (f *LatencyControlledFlow) DecRef() {
	f.refCount -= 1
}