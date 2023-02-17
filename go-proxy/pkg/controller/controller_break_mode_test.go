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
	dc := NewMockDeviceCallbacks(t)
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{
		ActivePreset: &proxyservice.Preset{
			BaseRxSpeedTarget:      1e6,
			TemporaryRxSpeedTarget: math.Inf(1),
			TemporaryRxSpeedExpiry: timestamppb.New(time.Now().Add(time.Second)),
		},
	})
	assert.NotNil(t, c.temporaryTimer)
	assert.Equal(t, c.RxSpeedTarget(), math.Inf(1))
}

func TestSetSettingsFiresCheatTimersOnChange(t *testing.T) {
	dc := NewMockDeviceCallbacks(t)
	c := Init(&analytics.NoOpAnalytics{}, InitSettingsManager(), testAppConfigs, dc)

	c.SetSettings(&proxyservice.Settings{ActivePreset: &proxyservice.Preset{BaseRxSpeedTarget: 1e6}})
	assert.Nil(t, c.temporaryTimer)
	assert.Equal(t, c.RxSpeedTarget(), 1e6)

	c.SetSettings(&proxyservice.Settings{
		ActivePreset: &proxyservice.Preset{
			BaseRxSpeedTarget:      1e6,
			TemporaryRxSpeedTarget: math.Inf(1),
			TemporaryRxSpeedExpiry: timestamppb.New(time.Now().Add(time.Second)),
		},
	})
	assert.NotNil(t, c.temporaryTimer)
	assert.Equal(t, c.RxSpeedTarget(), math.Inf(1))

	c.SetSettings(&proxyservice.Settings{
		ActivePreset: &proxyservice.Preset{
			BaseRxSpeedTarget:      1e6,
			TemporaryRxSpeedTarget: math.Inf(1),
			TemporaryRxSpeedExpiry: timestamppb.New(time.Now().Add(-1 * time.Second)),
		},
	})
	assert.Nil(t, c.temporaryTimer)
	assert.Equal(t, c.RxSpeedTarget(), 1e6)
}
