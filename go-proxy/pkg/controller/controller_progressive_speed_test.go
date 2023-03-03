package controller

import (
	"math"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	mock "github.com/stretchr/testify/mock"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
)

func TestProgressive_defaultsNoBaseSlowing(t *testing.T) {
	dc := NewMockDeviceCallbacks(t)
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{
		DefaultPreset: &proxyservice.Preset{
			BaseRxSpeedTarget: 1e6, // unused
			UsageHealRate:     0.5,
			UsageMaxHP:        6,
		},
	})

	c.RegisterDnsEntry("1.2.3.4", "hello.com.")
	flow := InitControllableFlow(c, "1.2.3.4")

	assert.EqualValues(t, flow.makeDecision().rxSpeedTarget, math.Inf(1))
}

func TestProgressive__slowsWithBaseSpeed(t *testing.T) {
	dc := NewMockDeviceCallbacks(t)
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{
		DefaultPreset: &proxyservice.Preset{
			BaseRxSpeedTarget:      1e6, // unused
			UsageHealRate:          0.5,
			UsageMaxHP:             6,
			UsageBaseRxSpeedTarget: 50e3,
		},
	})

	c.RegisterDnsEntry("1.2.3.4", "hello.com.")
	flow := InitControllableFlow(c, "1.2.3.4")

	assert.EqualValues(t, flow.makeDecision().rxSpeedTarget, 50e3)
}

func TestProgressive__startsProgressiveSlowingAtHalfwayPoint(t *testing.T) {
	dc := NewMockDeviceCallbacks(t)
	dc.On("SendNotification", mock.Anything, mock.Anything).Maybe().Return()
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{
		DefaultPreset: &proxyservice.Preset{
			BaseRxSpeedTarget:      1e6, // unused
			UsageHealRate:          0.5,
			UsageMaxHP:             4,
			UsageBaseRxSpeedTarget: 100e3,
		},
	})
	now := time.Now()
	a := c.apps[0]

	c.RegisterDnsEntry("1.2.3.4", "hello.com.")
	flow := InitControllableFlow(c, "1.2.3.4")

	assert.EqualValues(t, flow.makeDecision().rxSpeedTarget, 100e3)

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(2 * time.Minute)
	a.ResetSampleState()

	assert.Equal(t, 2.0, c.usagePoints.Points())
	assert.EqualValues(t, flow.makeDecision().rxSpeedTarget, 100e3)

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(1 * time.Minute)
	a.ResetSampleState()

	assert.Equal(t, 3.0, c.usagePoints.Points())
	assert.EqualValues(t, math.Pow(40e3, 0.5)*math.Pow(100e3, 0.5), flow.makeDecision().rxSpeedTarget)

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(1 * time.Minute)
	a.ResetSampleState()

	assert.Equal(t, 4.0, c.usagePoints.Points())
	assert.EqualValues(t, 40e3, flow.makeDecision().rxSpeedTarget)
}

func TestProgressive__usesDefaultMaxSpeedOf10Mbps(t *testing.T) {
	dc := NewMockDeviceCallbacks(t)
	dc.On("SendNotification", mock.Anything, mock.Anything).Maybe().Return()
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{
		DefaultPreset: &proxyservice.Preset{
			BaseRxSpeedTarget: 1e6, // unused
			UsageHealRate:     0.5,
			UsageMaxHP:        4,
		},
	})
	now := time.Now()
	a := c.apps[0]

	c.RegisterDnsEntry("1.2.3.4", "hello.com.")
	flow := InitControllableFlow(c, "1.2.3.4")

	assert.EqualValues(t, math.Inf(1), flow.makeDecision().rxSpeedTarget)

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(2 * time.Minute)
	a.ResetSampleState()

	assert.Equal(t, 2.0, c.usagePoints.Points())
	assert.EqualValues(t, 10e6, flow.makeDecision().rxSpeedTarget)

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(1 * time.Minute)
	a.ResetSampleState()

	assert.Equal(t, 3.0, c.usagePoints.Points())
	assert.EqualValues(t, math.Pow(40e3, 0.5)*math.Pow(10e6, 0.5), flow.makeDecision().rxSpeedTarget)

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(1 * time.Minute)
	a.ResetSampleState()

	assert.Equal(t, 4.0, c.usagePoints.Points())
	assert.EqualValues(t, 40e3, flow.makeDecision().rxSpeedTarget)
}
