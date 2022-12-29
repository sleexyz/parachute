package controller

import (
	"context"
	"log"
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
	settings       *proxyservice.Settings
	temporaryTimer *time.Timer
	fm             map[string]*ControllableFlow
	gcTicker       *time.Ticker
	stopGcTicker   func()
}

func Init(sp analytics.SamplePublisher) *Controller {
	ao := &AppResolverOptions{
		failedIpMatchCacheSize:  1024,
		failedDnsMatchCacheSize: 1024,
		apps:                    prodApps,
	}
	c := &Controller{
		AppResolver:     InitAppResolver(ao),
		SamplePublisher: sp,
		fm:              make(map[string]*ControllableFlow),
	}
	c.Start()
	return c
}

func (c *Controller) RxSpeedTarget() float64 {
	if c.temporaryTimer != nil {
		return c.settings.TemporaryRxSpeedTarget
	}
	return c.settings.BaseRxSpeedTarget
}

func (c *Controller) SetSettings(settings *proxyservice.Settings) {
	log.Printf("set settings: %s", settings)
	oldSettings := c.settings
	c.settings = settings

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
	ctx, cancel := context.WithCancel(context.Background())
	c.stopGcTicker = func() {
		c.gcTicker.Stop()
		cancel()
	}
	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			case <-c.gcTicker.C:
				c.GarbageCollect()
			}
		}
	}()
}

func (c *Controller) Close() {
	c.stopGcTicker()
}

func (c *Controller) GarbageCollect() {
	// now := time.Now()
	log.Printf("garbage collection started")
	for k, v := range c.fm {
		if v != nil && v.refCount == 0 {
			log.Printf("deleting %s", c.fm[k].ip)
			delete(c.fm, k)
		}
	}
}

func (c *Controller) ResetState() {
	for k := range c.fm {
		delete(c.fm, k)
	}
}

func (c *Controller) RecordState() *proxyservice.ServerState {
	return c.AppResolver.RecordState()
}
