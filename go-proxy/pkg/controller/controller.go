package controller

import (
	"context"
	"time"

	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
)

const (
	// defaultRxSpeedTarget = 40000.0 // dialup (40kbps)
	// DefaultRxSpeedTarget float64 = 100000.0 // 100kbps
	DefaultRxSpeedTarget float64 = 56000.0 // 100kbps
)

type ControllerSettingsReadWrite interface {
	ResetState()
	SetSettings(settings *proxyservice.Settings)
}

type Controller struct {
	*AppResolver
	analytics.SamplePublisher
	sm             *SettingsManager
	temporaryTimer *time.Timer
	fm             map[string]*ControllableFlow
	gcTicker       *time.Ticker

	lastAppUsageUpdatedTime *time.Time
	appUsageUpdateTicker    *time.Ticker
	appUsageUpdateCounter   int

	stopTickers func()
}

func Init(sp analytics.SamplePublisher, appConfigs []*AppConfig) *Controller {
	sm := InitSettingsManager()
	ao := &AppResolverOptions{
		failedIpMatchCacheSize:  1024,
		failedDnsMatchCacheSize: 1024,
		apps:                    InitApps(appConfigs, sm),
	}
	c := &Controller{
		sm:              sm,
		AppResolver:     InitAppResolver(ao),
		SamplePublisher: sp,
		fm:              make(map[string]*ControllableFlow),
	}
	sm.RegisterChangeListener(c)
	c.Start()
	return c
}

func (c *Controller) RxSpeedTarget() float64 {
	if c.temporaryTimer != nil {
		return c.sm.Settings().TemporaryRxSpeedTarget
	}
	return c.sm.Settings().BaseRxSpeedTarget
}

func (c *Controller) SetSettings(settings *proxyservice.Settings) {
	c.sm.SetSettings(settings)
}

func (c *Controller) BeforeSettingsChange() {
	c.updateAppUsagePoints()
}

func (c *Controller) OnSettingsChange(oldSettings *proxyservice.Settings, settings *proxyservice.Settings) {
	if oldSettings == nil || oldSettings.TemporaryRxSpeedExpiry != settings.TemporaryRxSpeedExpiry {
		expiry := settings.TemporaryRxSpeedExpiry.AsTime()
		if expiry.After(time.Now()) {
			c.setTemporaryRxSpeedTimer(expiry)
		} else {
			c.evictExistingTimer()
		}
	}
}

func (c *Controller) evictExistingTimer() {
	if c.temporaryTimer != nil {
		c.temporaryTimer.Stop()
		c.temporaryTimer = nil
	}
}

func (c *Controller) setTemporaryRxSpeedTimer(expiry time.Time) {
	c.evictExistingTimer()
	c.temporaryTimer = time.NewTimer(expiry.Sub(time.Now()))
	go func() {
		if c.temporaryTimer == nil {
			return
		}
		<-c.temporaryTimer.C
		c.evictExistingTimer()
	}()
}

func (c *Controller) GetFlow(ip string) *ControllableFlow {
	if _, ok := c.fm[ip]; !ok {
		c.fm[ip] = InitControllableFlow(c, ip)
		c.RegisterIp(ip)
	}
	f := c.fm[ip]
	f.IncRef()
	return f
}

func (c *Controller) Start() {
	c.gcTicker = time.NewTicker(1 * time.Minute)
	now := time.Now()
	c.lastAppUsageUpdatedTime = &now
	c.appUsageUpdateTicker = time.NewTicker(5 * time.Second)
	ctx, cancel := context.WithCancel(context.Background())
	c.stopTickers = func() {
		c.gcTicker.Stop()
		c.appUsageUpdateTicker.Stop()
		cancel()
	}
	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			case <-c.gcTicker.C:
				c.garbageCollect()
			case <-c.appUsageUpdateTicker.C:
				// Currently we use overload this ticker to both
				// 1) update app health, and
				// 2) sample app tx points
				c.updateAppUsagePoints()
				c.appUsageUpdateCounter = (c.appUsageUpdateCounter + 1) % 6
				if c.appUsageUpdateCounter == 0 {
					c.resetAppSampleStates()
				}
			}
		}
	}()
}

func (c *Controller) Close() {
	c.stopTickers()
}

func (c *Controller) garbageCollect() {
	for k, v := range c.fm {
		if v != nil && v.IsUnused() {
			delete(c.fm, k)
		}
	}
}

func (c *Controller) updateAppUsagePoints() {
	now := time.Now()
	dt := now.Sub(*c.lastAppUsageUpdatedTime)
	for _, app := range c.apps {
		app.UpdateUsagePoints(dt, &now)
	}
	c.lastAppUsageUpdatedTime = &now
}

func (c *Controller) resetAppSampleStates() {
	for _, app := range c.apps {
		app.ResetSampleState()
	}
}

// TODO: delete
func (c *Controller) ResetState() {
	for k := range c.fm {
		delete(c.fm, k)
	}
}

func (c *Controller) RecordState() *proxyservice.ServerState {
	return c.AppResolver.RecordState()
}

func (c *Controller) DebugGetEntries(ip string) []string {
	return c.failedDnsMatchCache.DebugGetEntries(ip)
}
