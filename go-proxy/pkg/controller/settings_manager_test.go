package controller

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"google.golang.org/protobuf/types/known/timestamppb"
	"strange.industries/go-proxy/pb/proxyservice"
)

func TestUsesOverlayAsActivePreset(t *testing.T) {
	sm := InitSettingsManager()
	sm.SetSettings(&proxyservice.Settings{
		DefaultPreset: &proxyservice.Preset{
			Id: "foo",
		},
		Overlay: &proxyservice.Overlay{
			Preset: &proxyservice.Preset{
				Id: "bar",
			},
			Expiry: timestamppb.New(time.Now().Add(time.Second)),
		},
	})
	assert.Equal(t, "bar", sm.ActivePreset().Id)
}

func TestSkipsExpiredOverlayAsActivePreset(t *testing.T) {
	sm := InitSettingsManager()
	sm.SetSettings(&proxyservice.Settings{
		DefaultPreset: &proxyservice.Preset{
			Id: "foo",
		},
		Overlay: &proxyservice.Overlay{
			Preset: &proxyservice.Preset{
				Id: "bar",
			},
			Expiry: timestamppb.New(time.Now().Add(-1 * time.Second)),
		},
	})
	assert.Equal(t, "foo", sm.ActivePreset().Id)
}
