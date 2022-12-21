package controller

import (
	"log"
	"math"
	"time"

	"google.golang.org/protobuf/types/known/timestamppb"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
)

type ControllableFlow struct {
	*FlowBase
	analytics.SamplePublisher
	c        *Controller
	refCount int
	gain     float64
	fdate    *time.Time
	ip       string
}

func InitControllableFlow(c *Controller, ip string) *ControllableFlow {
	// log.Printf("initial latency per byte: %s", initialLatencyPerByte)
	now := time.Now()
	ret := &ControllableFlow{
		FlowBase:        InitFlowBase(),
		SamplePublisher: c,
		c:               c,
		refCount:        1,
		fdate:           pointsToFdate(0, &now),
		gain:            1000,
		ip:              ip,
	}
	ret.Initialize()
	ret.Updater = ret
	return ret
}

func (c *ControllableFlow) Initialize() {
	if !c.isEnabled() {
		return
	}
	now := time.Now()
	st := c.c.settings.GetBaseRxSpeedTarget()
	if c.c.UseExponentialDecay() {
		st, _, _ = c.computeExpDecay(now)
	}
	c.SetRxLatencyPerByte(18 * time.Microsecond * 400000.0 / time.Duration(st))
}

func (c *ControllableFlow) Controller() *Controller {
	return c.c
}

func (c *ControllableFlow) IncRef() {
	c.refCount += 1
}

func (c *ControllableFlow) DecRef() {
	c.refCount -= 1
}

func (s *ControllableFlow) isEnabled() bool {
	return s.c.ShouldSlow(s.ip) && !math.IsInf(s.c.RxSpeedTarget(), 1)
}

func (s *ControllableFlow) computeExpDecay(now time.Time) (float64, float64, float64) {
	points := fdateToPoints(s.fdate, &now)
	k := math.Pow(4, math.Pow(lambda, points*20))
	st := s.c.RxSpeedTarget() * k
	return st, k, points
}

func (s *ControllableFlow) UpdateFn(n int, now time.Time, dt time.Duration) {
	// Update rxSpeed
	s.FlowBase.UpdateFn(n, now, dt)

	sample := &proxyservice.Sample{}
	sample.Ip = s.ip
	sample.RxBytes = int64(n)
	sample.StartTime = timestamppb.New(now)
	sample.Duration = int64(dt)
	sample.RxSpeed = s.RxSpeed()

	st := s.c.RxSpeedTarget()
	sample.RxSpeedTarget = st
	if s.c.UseExponentialDecay() {
		s.fdate = addPointsToFdate(s.fdate, 0.4*float64(n)/100000, &now)
		st, sample.K, sample.Points = s.computeExpDecay(now)
		sample.MinutesLeft = s.fdate.Sub(now).Minutes()
	}
	if !s.isEnabled() {
		s.SetRxLatencyPerByte(0)
		matches := s.c.GetReverseDnsEntry(s.ip)
		sample.Matches = matches
		log.Printf("(skipped) ip: %v, matches: %v", s.ip, matches)
	} else {
		e := (st - s.RxSpeed()) / st // proportional error
		update := -1.0 * time.Duration(e*s.gain)
		oldLatencyPerByte := s.RxLatencyPerByte()
		newLatencyPerByte := oldLatencyPerByte + update
		if newLatencyPerByte < 0 {
			newLatencyPerByte = 0
		}
		s.SetRxLatencyPerByte(newLatencyPerByte)
		matches := s.c.GetReverseDnsEntry(s.ip)
		sample.Matches = matches
		log.Printf("slowed. ip: %s, matches: %v", s.ip, matches)
	}
	go s.SamplePublisher.PublishSample(sample)
}
