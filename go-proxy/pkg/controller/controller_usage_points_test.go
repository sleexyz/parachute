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

	assert.Equal(t, 0.0, c.usagePoints.Points())

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(time.Minute)
	a.ResetSampleState()
}

func TestAppUpdateUsagePointsHealsAtHealRate(t *testing.T) {
	sm := InitSettingsManager()
	c := Init(&analytics.NoOpAnalytics{}, sm, testAppConfigs)
	c.SetSettings(&proxyservice.Settings{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6})
	now := time.Now()
	a := c.apps[0]

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(time.Minute)
	a.ResetSampleState()
	assert.Equal(t, 1.0, c.usagePoints.Points())

	// Heals
	c.UpdateUsagePoints(time.Minute)
	a.ResetSampleState()

	assert.Equal(t, 0.5, c.usagePoints.Points())
}

func TestAppUsagePointsNoopsUnderThreshold(t *testing.T) {
	sm := InitSettingsManager()
	c := Init(&analytics.NoOpAnalytics{}, sm, testAppConfigs)
	c.SetSettings(&proxyservice.Settings{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6})
	now := time.Now()
	a := c.apps[0]

	c.UpdateUsagePoints(time.Minute)
	a.ResetSampleState()
	assert.Equal(t, 0.0, c.usagePoints.Points())

	a.AddTxPoints(0.9, &now)
	c.UpdateUsagePoints(time.Minute)
	a.ResetSampleState()
	assert.Equal(t, 0.0, c.usagePoints.Points())
}

func TestAppUsagePointsRespondsToSettingsUpdate(t *testing.T) {
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
	c.UpdateUsagePoints(time.Minute)
	a.ResetSampleState()

	assert.Equal(t, 1.0, c.usagePoints.Points())

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(5 * time.Minute)
	a.ResetSampleState()

	assert.Equal(t, 3.0, c.usagePoints.Points(), "should be capped")
}

func TestHealHealsToHpMin(t *testing.T) {
	sm := InitSettingsManager()
	c := Init(&analytics.NoOpAnalytics{}, sm, testAppConfigs)
	c.SetSettings(&proxyservice.Settings{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6})
	now := time.Now()
	a := c.apps[0]

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(6 * time.Minute)
	a.ResetSampleState()
	assert.Equal(t, 6.0, c.usagePoints.Points())

	c.Heal()
	assert.Equal(t, 2.0, c.usagePoints.Points())

	c.Heal()
	assert.Equal(t, 1.0, c.usagePoints.Points())

	c.Heal()
	assert.Equal(t, 0.0, c.usagePoints.Points())
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
