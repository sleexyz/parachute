package controller

import (
	"math"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"google.golang.org/protobuf/types/known/timestamppb"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
)

func TestSetSettingsFiresCheatTimersOnInit(t *testing.T) {
	c := Init(&analytics.NoOpAnalytics{})
	c.SetSettings(&proxyservice.Settings{
		BaseRxSpeedTarget:      1e6,
		TemporaryRxSpeedTarget: math.Inf(1),
		TemporaryRxSpeedExpiry: timestamppb.New(time.Now().Add(time.Second)),
	})
	assert.NotNil(t, c.temporaryTimer)
	assert.Equal(t, c.RxSpeedTarget(), math.Inf(1))
}

func TestSetSettingsFiresCheatTimersOnChange(t *testing.T) {
	c := Init(&analytics.NoOpAnalytics{})
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
