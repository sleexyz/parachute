package controller

import (
	"math"
	"time"
)

// decay factor: 30 minute half life
// =0.5^(1/30)
// var lambda = math.Pow(0.5, 1/30)
// var lambda = 0.9771599684342459
var lambda = 0.98851402035

// Continuous frecency with no recomputations.
// Source: https://wiki.mozilla.org/User:Jesse/NewFrecency
func addPointsToFdate(fdate *time.Time, points float64, now *time.Time) *time.Time {
	if now == nil {
		n := time.Now()
		now = &n
	}
	if fdate == nil {
		return pointsToFdate(points, now)
	}
	return pointsToFdate(fdateToPoints(fdate, now)+points, now)
}

func pointsToFdate(points float64, now *time.Time) *time.Time {
	if now == nil {
		n := time.Now()
		now = &n
	}
	fdate := now.Add(time.Duration(-1.0 * math.Log1p(points) / math.Log(lambda) * 60 * 1000000000))
	return &fdate
}

func fdateToPoints(fdate *time.Time, now *time.Time) float64 {
	if now == nil {
		n := time.Now()
		now = &n
	}
	return math.Pow(lambda, float64(now.Sub(*fdate).Minutes())) - 1
}
