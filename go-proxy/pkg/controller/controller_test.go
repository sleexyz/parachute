package controller

import (
	"math"
	"regexp"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"google.golang.org/protobuf/types/known/timestamppb"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
)

var testAppConfigs = []*AppConfig{
	{
		name: "social",
		matchers: &AppMatcher{
			dnsMatchers: []*regexp.Regexp{
				regexp.MustCompile(`hello\.com\.$`),
			},
		},
	},
}

func TestSetSettingsFiresCheatTimersOnInit(t *testing.T) {
	c := Init(&analytics.NoOpAnalytics{}, testAppConfigs)
	c.SetSettings(&proxyservice.Settings{
		BaseRxSpeedTarget:      1e6,
		TemporaryRxSpeedTarget: math.Inf(1),
		TemporaryRxSpeedExpiry: timestamppb.New(time.Now().Add(time.Second)),
	})
	assert.NotNil(t, c.temporaryTimer)
	assert.Equal(t, c.RxSpeedTarget(), math.Inf(1))
}

func TestSetSettingsFiresCheatTimersOnChange(t *testing.T) {
	c := Init(&analytics.NoOpAnalytics{}, testAppConfigs)
	c.SetSettings(&proxyservice.Settings{BaseRxSpeedTarget: 1e6})
	assert.Nil(t, c.temporaryTimer)
	assert.Equal(t, c.RxSpeedTarget(), 1e6)

	c.SetSettings(&proxyservice.Settings{
		BaseRxSpeedTarget:      1e6,
		TemporaryRxSpeedTarget: math.Inf(1),
		TemporaryRxSpeedExpiry: timestamppb.New(time.Now().Add(time.Second)),
	})
	assert.NotNil(t, c.temporaryTimer)
	assert.Equal(t, c.RxSpeedTarget(), math.Inf(1))

	c.SetSettings(&proxyservice.Settings{
		BaseRxSpeedTarget:      1e6,
		TemporaryRxSpeedTarget: math.Inf(1),
		TemporaryRxSpeedExpiry: timestamppb.New(time.Now().Add(-1 * time.Second)),
	})
	assert.Nil(t, c.temporaryTimer)
	assert.Equal(t, c.RxSpeedTarget(), 1e6)
}

func TestSettingsChangeCausesSample(t *testing.T) {
	c := Init(&analytics.NoOpAnalytics{}, testAppConfigs)
	c.SetSettings(&proxyservice.Settings{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6})
	c.RegisterDnsEntry("1.2.3.4", "hello.com.")
	now := time.Now()

	c.appMap["1.2.3.4"].AddTxPoints(1.0, &now)
	// time.Sleep(time.Second)
	c.SetSettings(&proxyservice.Settings{BaseRxSpeedTarget: 1e6, UsageHealRate: 0.5, UsageMaxHP: 6})

	// expect miniscule change from dt
	assert.Greater(t, c.appMap["1.2.3.4"].usagePoints.Points(&now), 0.0)
}
