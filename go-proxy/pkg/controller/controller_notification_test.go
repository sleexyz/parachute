package controller

import (
	"testing"
	"time"

	mock "github.com/stretchr/testify/mock"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
)

func TestAlertsOnSlowStart(t *testing.T) {
	dc := NewMockDeviceCallbacks(t)
	dc.On("SendNotification", "Slowing it down now...", mock.Anything).Return()
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)
	c.SetSettings(&proxyservice.Settings{ActivePreset: &proxyservice.Preset{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6}})

	now := time.Now()
	a := c.apps[0]

	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(3 * time.Minute)
	a.ResetSampleState()

	dc.On("SendNotification", "Really slowing it down now...", mock.Anything).Return()
	a.AddTxPoints(1.0, &now)
	c.UpdateUsagePoints(3 * time.Minute)
}
