package controller

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	mock "github.com/stretchr/testify/mock"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
)

func TestAppUpdateUsagePointsAboveThreshold(t *testing.T) {
	dc := NewMockDeviceCallbacks(t)
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{ActivePreset: &proxyservice.Preset{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6}})
	now := time.Now()
	a := c.apps[0]

	assert.Equal(t, 0.0, c.usagePoints.Points())

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(time.Minute)
	a.ResetSampleState()
}

func TestAppUpdateUsagePointsHealsAtHealRate(t *testing.T) {
	dc := NewMockDeviceCallbacks(t)
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{ActivePreset: &proxyservice.Preset{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6}})
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
	dc := NewMockDeviceCallbacks(t)
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{ActivePreset: &proxyservice.Preset{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6}})
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
	dc := NewMockDeviceCallbacks(t)
	dc.On("SendNotification", mock.Anything, mock.Anything).Maybe().Return()
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{ActivePreset: &proxyservice.Preset{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6}})
	now := time.Now()
	a := c.apps[0]

	a.AddTxPoints(1.0, &now)
	c.sm.SetSettings(&proxyservice.Settings{ActivePreset: &proxyservice.Preset{UsageHealRate: 1, UsageMaxHP: 3}})
	c.UpdateUsagePoints(time.Minute)
	a.ResetSampleState()

	assert.Equal(t, 1.0, c.usagePoints.Points())

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(5 * time.Minute)
	a.ResetSampleState()

	assert.Equal(t, 3.0, c.usagePoints.Points(), "should be capped")
}

func TestHealHealsToMaxHp(t *testing.T) {
	dc := NewMockDeviceCallbacks(t)
	dc.On("SendNotification", mock.Anything, mock.Anything).Maybe().Return()
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{ActivePreset: &proxyservice.Preset{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6}})
	now := time.Now()
	a := c.apps[0]

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(6 * time.Minute)
	a.ResetSampleState()
	assert.Equal(t, 6.0, c.usagePoints.Points())

	c.Heal()
	assert.Equal(t, 0.0, c.usagePoints.Points())
}
