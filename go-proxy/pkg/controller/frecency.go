package controller

import (
	"math"
	"time"
)

// Exponentially decaying points
type ExpPoints struct {
	lambda float64
	cap    float64
	fdate  *time.Time
}

func InitExpPoints(lambda float64, cap float64) *ExpPoints {
	return &ExpPoints{
		lambda: lambda,
		cap:    cap,
		fdate:  PointsToFdate(0, lambda, nil),
	}
}

func (p *ExpPoints) Fdate() *time.Time {
	return p.fdate
}

func (p *ExpPoints) Points() float64 {
	return FdateToPoints(p.fdate, p.lambda, nil)
}

// returns new points
func (p *ExpPoints) AddPoints(points float64, now *time.Time) float64 {
	oldPoints := FdateToPoints(p.fdate, p.lambda, now)
	newPoints := math.Min(points+oldPoints, p.cap)
	p.fdate = PointsToFdate(newPoints, p.lambda, now)
	return newPoints
}

// decay factor: 1 minute half life
// =0.5^(1/30)
// var lambda = math.Pow(0.5, 1/30)
// var lambda = 0.9771599684342459
// var lambda = 0.98851402035

// Continuous frecency with no recomputations.
// Source: https://wiki.mozilla.org/User:Jesse/NewFrecency

func PointsToFdate(points float64, lambda float64, now *time.Time) *time.Time {
	if now == nil {
		n := time.Now()
		now = &n
	}
	fdate := now.Add(time.Duration(-1.0 * math.Log(points) / math.Log(lambda) * 1e9))
	return &fdate
}

func FdateToPoints(fdate *time.Time, lambda float64, now *time.Time) float64 {
	if now == nil {
		n := time.Now()
		now = &n
	}
	return math.Pow(lambda, float64(now.Sub(*fdate).Seconds()))
}
