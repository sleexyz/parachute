package controller

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
)

func TestAppUpdateUsagePointsAboveThreshold(t *testing.T) {
	sm := InitSettingsManager()
	c := Init(&analytics.NoOpAnalytics{}, sm, testAppConfigs)
	c.SetSettings(&proxyservice.Settings{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6})
	now := time.Now()
	a := c.apps[0]

	assert.Equal(t, 0.0, c.usagePoints.Points(&now))

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(time.Minute, &now)
	a.ResetSampleState()

	// 1 minute * 0.5 points per minute + 1 minute * 1 point per minute = 1.5
	assert.Equal(t, 1.5, c.usagePoints.Points(&now))
}

func TestAppUsagePointsNoopsUnderThreshold(t *testing.T) {
	sm := InitSettingsManager()
	c := Init(&analytics.NoOpAnalytics{}, sm, testAppConfigs)
	c.SetSettings(&proxyservice.Settings{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6})
	now := time.Now()
	a := c.apps[0]

	c.UpdateUsagePoints(time.Minute, &now)
	a.ResetSampleState()
	assert.Equal(t, 0.0, c.usagePoints.Points(&now))

	a.AddTxPoints(0.9, &now)
	c.UpdateUsagePoints(time.Minute, &now)
	a.ResetSampleState()
	assert.Equal(t, 0.0, c.usagePoints.Points(&now))
}

func TestAppUsagePointsRespondsToUpdate(t *testing.T) {
	sm := InitSettingsManager()
	c := Init(&analytics.NoOpAnalytics{}, sm, testAppConfigs)
	c.SetSettings(&proxyservice.Settings{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6})
	now := time.Now()
	a := c.apps[0]

	a.AddTxPoints(1.0, &now)
	c.sm.SetSettings(&proxyservice.Settings{
		UsageHealRate: 1,
		UsageMaxHP:    3,
	})
	c.UpdateUsagePoints(time.Minute, &now)
	a.ResetSampleState()

	// NOTE: This has the interesting property of healing more than
	// we waited for since we compensate against the new heal rate.
	// We can instead heal.
	// To ameliorate this, we have a few choices:
	// 1) Adjust usage HP more often, while keeping sample rate fixed
	// 2) Adjust usageHP immediately when setting changes, at the old rate.
	//    Note we don't want to sample again
	// Choice -- (2) is the more correct solution.
	assert.Equal(t, 2.0, c.usagePoints.Points(&now), "should reflect change in heal rate")

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(time.Minute, &now)
	a.ResetSampleState()

	assert.Equal(t, 3.0, c.usagePoints.Points(&now), "should be capped")
}

// func TestSettingsChangeCausesSample(t *testing.T) {
// 	c := Init(&analytics.NoOpAnalytics{}, testAppConfigs)
// 	c.SetSettings(&proxyservice.Settings{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6})
// 	c.RegisterDnsEntry("1.2.3.4", "hello.com.")
// 	now := time.Now()

// 	c.appMap["1.2.3.4"].AddTxPoints(1.0, &now)
// 	// time.Sleep(time.Second)
// 	c.SetSettings(&proxyservice.Settings{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6})

// 	// expect miniscule change from dt
// 	assert.Greater(t, c.usagePoints.Points(&now), 0.0)
// }
