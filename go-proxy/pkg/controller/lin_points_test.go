package controller

import (
	"math"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestLinPointsCanAddPoints(t *testing.T) {
	p := InitLinPoints(0.5, 6)
	now := time.Now()
	assert.Equal(t, 0.0, p.Points(&now))

	p.AddPoints(0.25, &now)
	assertApproximate(t, 0.25, p.Points(&now))

	zeroTime := now.Add(time.Minute / 2)
	assertApproximate(t, 0, p.Points(&zeroTime))
}

func TestLinPointsOldFdate(t *testing.T) {
	p := InitLinPoints(0.25, 6)
	now := time.Now()

	future := now.Add(time.Minute)
	p.AddPoints(1, &future)
	assertApproximate(t, 1, p.Points(&future))
}

func assertApproximate(t assert.TestingT, a float64, b float64) {
	assert.Equal(t, math.Round(a*100)/100, math.Round(b*100)/100)
}
