package controller

import (
	"math"
	"time"
)

// Linearly decaying points
type LinPoints struct {
	healRate float64
	cap      float64
	fdate    *time.Time
}

func InitLinPoints(healRate float64, cap float64) *LinPoints {
	now := time.Now()
	return &LinPoints{
		healRate: healRate, // points per minute
		cap:      cap,
		fdate:    &now,
	}
}

func (p *LinPoints) SetHealRate(healRate float64) {
	p.healRate = healRate
}

func (p *LinPoints) SetCap(cap float64) {
	p.cap = cap
}

func (p *LinPoints) Fdate() *time.Time {
	return p.fdate
}

func (p *LinPoints) Points(now *time.Time) float64 {
	return p.clampPoints(p.fdateToPoints(p.fdate, now))
}

func (p *LinPoints) clampPoints(points float64) float64 {
	return math.Max(math.Min(points, p.cap), 0)
}

func (p *LinPoints) fdateToPoints(fdate *time.Time, now *time.Time) float64 {
	return p.DurationToPoints(fdate.Sub(*now))
}

func (p *LinPoints) DurationToPoints(dur time.Duration) float64 {
	minutes := dur.Minutes()
	return minutes * p.healRate
}

func (p *LinPoints) pointsToDuration(points float64) time.Duration {
	return time.Duration(points / p.healRate * float64(time.Minute))
}

// returns new points
func (p *LinPoints) AddPoints(points float64, now *time.Time) float64 {
	newPoints := p.clampPoints(points + p.clampPoints(p.fdateToPoints(p.fdate, now)))
	newDate := now.Add(p.pointsToDuration(newPoints))
	p.fdate = &newDate
	return newPoints
}

func (p *LinPoints) ProgressiveRxSpeedTarget() float64 {
	ratio := p.HP() / p.cap
	if ratio < 1.0/6.0 {
		return 50e3
	}
	if ratio < 2.0/6.0 {
		return 100e3
	}
	if ratio < 3.0/6.0 {
		return 200e3
	}
	return math.Inf(1)
}

func (p *LinPoints) HP() float64 {
	now := time.Now()
	return p.cap - p.Points(&now)
}
