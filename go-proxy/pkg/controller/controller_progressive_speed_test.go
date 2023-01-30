package controller

import (
	"math"
	"testing"

	"github.com/stretchr/testify/assert"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
)

func TestProgressive_defaultsNoBaseSlowing(t *testing.T) {
	dc := NewMockDeviceCallbacks(t)
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{
		BaseRxSpeedTarget: 1e6, // unused
		UsageHealRate:     0.5,
		UsageMaxHP:        6,
	})

	c.RegisterDnsEntry("1.2.3.4", "hello.com.")
	flow := InitControllableFlow(c, "1.2.3.4")

	assert.EqualValues(t, flow.makeDecision().rxSpeedTarget, math.Inf(1))
}

func TestProgressive__slowsWithBaseSpeed(t *testing.T) {
	dc := NewMockDeviceCallbacks(t)
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{
		BaseRxSpeedTarget:      1e6, // unused
		UsageHealRate:          0.5,
		UsageMaxHP:             6,
		UsageBaseRxSpeedTarget: 50e3,
	})

	c.RegisterDnsEntry("1.2.3.4", "hello.com.")
	flow := InitControllableFlow(c, "1.2.3.4")

	assert.EqualValues(t, flow.makeDecision().rxSpeedTarget, 50e3)
}
