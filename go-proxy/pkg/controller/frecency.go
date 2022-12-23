package controller

import (
	"math"
	"time"
)

// decay factor: 1 minute half life
// =0.5^(1/30)
// var lambda = math.Pow(0.5, 1/30)
// var lambda = 0.9771599684342459
// var lambda = 0.98851402035

// Continuous frecency with no recomputations.
// Source: https://wiki.mozilla.org/User:Jesse/NewFrecency
type PointsSystem struct {
	lambda float64
}

func (ps *PointsSystem) PointsToFdate(points float64, now *time.Time) *time.Time {
	if now == nil {
		n := time.Now()
		now = &n
	}
	fdate := now.Add(time.Duration(-1.0 * math.Log(points) / math.Log(ps.lambda) * 1e9))
	return &fdate
}

func (ps *PointsSystem) FdateToPoints(fdate *time.Time, now *time.Time) float64 {
	if now == nil {
		n := time.Now()
		now = &n
	}
	return math.Pow(ps.lambda, float64(now.Sub(*fdate).Seconds()))
}
