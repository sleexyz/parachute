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

type Controller struct {
	*AppResolver
	analytics.SamplePublisher
	sm             SettingsManager
	dc             DeviceCallbacks
	temporaryTimer *time.Timer
	fm             map[string]*ControllableFlow
	gcTicker       *time.Ticker

	lastAppUsageUpdatedTime *time.Time
	usageUpdateTicker       *time.Ticker
	usageUpdateCounter      int
	usagePoints             *Points

	stopTickers func()
}

func Init(sp analytics.SamplePublisher, sm SettingsManager, appConfigs []*AppConfig, dc DeviceCallbacks) *Controller {
	ao := &AppResolverOptions{
		failedIpMatchCacheSize:  1024,
		failedDnsMatchCacheSize: 1024,
		apps:                    InitApps(appConfigs),
	}
	c := &Controller{
		sm:              sm,
		dc:              dc,
		AppResolver:     InitAppResolver(ao),
		SamplePublisher: sp,
		usagePoints:     InitPoints(sm.Settings().UsageMaxHP),
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
	// c.updateAppUsagePoints()
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
	c.usagePoints.SetCap(settings.UsageMaxHP)
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
	c.usageUpdateTicker = time.NewTicker(5 * time.Second)
	ctx, cancel := context.WithCancel(context.Background())
	c.stopTickers = func() {
		c.gcTicker.Stop()
		c.usageUpdateTicker.Stop()
		cancel()
	}
	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			case <-c.gcTicker.C:
				c.garbageCollect()
			case <-c.usageUpdateTicker.C:
				// Currently we use overload this ticker to both
				// 1) update app health, and
				// 2) sample app tx points
				c.updateUsagePoints()
				c.usageUpdateCounter = (c.usageUpdateCounter + 1) % 6
				if c.usageUpdateCounter == 0 {
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

func (c *Controller) updateUsagePoints() {
	now := time.Now()
	dt := now.Sub(*c.lastAppUsageUpdatedTime)
	c.UpdateUsagePoints(dt)
	c.lastAppUsageUpdatedTime = &now
}

func (c *Controller) alert(oldValue float64) {
	newValue := c.usagePoints.Points()

	damageThreshold := c.usagePoints.cap / 2
	if oldValue < damageThreshold && newValue >= damageThreshold {
		c.dc.SendNotification("Slowing it down now...", "Time to take a break?")
		return
	}

	damageThreshold = c.usagePoints.cap - (c.usagePoints.cap / 6.0)
	if oldValue < damageThreshold && newValue >= damageThreshold {
		c.dc.SendNotification("Really slowing it down now...", "Time to take a break?")
		return
	}
}

func (c *Controller) UpdateUsagePoints(dt time.Duration) {
	oldValue := c.usagePoints.Points()
	defer c.usagePoints.LogDelta(oldValue)
	defer c.alert(oldValue)

	// Compute damage
	txPointsMax := 0.0
	for _, app := range c.apps {
		if app.txPointsMax > txPointsMax {
			txPointsMax = app.txPointsMax
		}
	}
	toAdd := float64(dt) / float64(time.Minute)
	multiplier := 1.0
	if txPointsMax < 1 {
		// Negative damage aka heal
		multiplier = -1 * c.sm.Settings().UsageHealRate
	}
	c.usagePoints.AddPoints(toAdd * multiplier)
}

func (c *Controller) resetAppSampleStates() {
	for _, app := range c.apps {
		app.ResetSampleState()
	}
}

func (c *Controller) Heal() {
	oldValue := c.usagePoints.Points()
	defer c.usagePoints.LogDelta(oldValue)
	c.usagePoints.HealTo(c.usagePoints.cap * 0.5)
	c.usagePoints.AddPoints(-1) // heal a minute
}

func (c *Controller) GetState() *proxyservice.GetStateResponse {
	return &proxyservice.GetStateResponse{
		UsagePoints: c.usagePoints.Points(),
	}
}

func (c *Controller) DebugRecordState() *proxyservice.ServerState {
	state := c.AppResolver.RecordState()
	state.UsagePoints = c.usagePoints.Points()
	state.Ratio = c.usagePoints.HP() / c.usagePoints.cap
	state.ProgressiveRxSpeedTarget = c.usagePoints.ProgressiveRxSpeedTarget()
	return state
}

func (c *Controller) DebugGetEntries(ip string) []string {
	return c.failedDnsMatchCache.DebugGetEntries(ip)
}
