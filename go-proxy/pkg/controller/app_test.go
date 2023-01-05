package controller

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestAppUpdateUsagePointsAboveThreshold(t *testing.T) {
	// 0.5 points per monute
	// cap: 6
	// floor: 0
	a := InitApp("test", &AppMatcher{})
	now := time.Now()

	assert.Equal(t, 0.0, a.usagePoints.Points(&now))

	// 1.0 is above or equal to threshhold
	a.AddTxPoints(1.0, &now)

	a.UpdateUsagePoints(time.Minute, &now)
	// 1 minute * 0.5 points per minute + 1 minute * 1 point per minute = 1.5
	assert.Equal(t, 1.5, a.usagePoints.Points(&now))
}
