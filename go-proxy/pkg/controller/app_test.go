package controller

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"strange.industries/go-proxy/pb/proxyservice"
)

func TestAppUpdateUsagePointsAboveThreshold(t *testing.T) {
	sp := InitSettingsManager()
	sp.settings.UsageHealRate = 0.5
	sp.settings.UsageMaxHP = 6

	a := InitApp(&AppConfig{
		name:     "test",
		matchers: &AppMatcher{},
	}, sp)
	now := time.Now()

	assert.Equal(t, 0.0, a.usagePoints.Points(&now))

	a.AddTxPoints(1.0, &now)
	a.UpdateUsagePoints(time.Minute, &now)
	a.ResetSampleState()

	// 1 minute * 0.5 points per minute + 1 minute * 1 point per minute = 1.5
	assert.Equal(t, 1.5, a.usagePoints.Points(&now))
}

func TestAppUsagePointsNoopsUnderThreshold(t *testing.T) {
	sp := InitSettingsManager()
	sp.settings.UsageHealRate = 0.5
	sp.settings.UsageMaxHP = 6

	a := InitApp(&AppConfig{
		name:     "test",
		matchers: &AppMatcher{},
	}, sp)
	now := time.Now()

	a.UpdateUsagePoints(time.Minute, &now)
	a.ResetSampleState()
	assert.Equal(t, 0.0, a.usagePoints.Points(&now))

	a.AddTxPoints(0.9, &now)
	a.UpdateUsagePoints(time.Minute, &now)
	a.ResetSampleState()
	assert.Equal(t, 0.0, a.usagePoints.Points(&now))
}

func TestAppUsagePointsRespondsToUpdate(t *testing.T) {
	sp := InitSettingsManager()
	sp.settings.UsageHealRate = 0.5
	sp.settings.UsageMaxHP = 6

	a := InitApp(&AppConfig{
		name:     "test",
		matchers: &AppMatcher{},
	}, sp)
	now := time.Now()

	a.AddTxPoints(1.0, &now)
	sp.SetSettings(&proxyservice.Settings{
		UsageHealRate: 1,
		UsageMaxHP:    3,
	})
	a.UpdateUsagePoints(time.Minute, &now)
	a.ResetSampleState()

	// NOTE: This has the interesting property of healing more than
	// we waited for since we compensate against the new heal rate.
	// We can instead heal.
	// To ameliorate this, we have a few choices:
	// 1) Adjust usage HP more often, while keeping sample rate fixed
	// 2) Adjust usageHP immediately when setting changes, at the old rate.
	//    Note we don't want to sample again
	// Choice -- (2) is the more correct solution.
	assert.Equal(t, 2.0, a.usagePoints.Points(&now), "should reflect change in heal rate")

	a.AddTxPoints(1.0, &now)
	a.UpdateUsagePoints(time.Minute, &now)
	a.ResetSampleState()

	assert.Equal(t, 3.0, a.usagePoints.Points(&now), "should be capped")
}
