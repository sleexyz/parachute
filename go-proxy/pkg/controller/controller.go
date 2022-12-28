package controller

import (
	"context"
	"log"
	"math"
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
	SetTemporaryRxSpeedTarget(target float64, seconds int)
}

type Controller struct {
	*AppResolver
	analytics.SamplePublisher
	settings               *proxyservice.Settings
	temporaryRxSpeedTarget float64
	temporaryTimer         *time.Timer
	fm                     map[string]*ControllableFlow
	gcTicker               *time.Ticker
	stopGcTicker           func()
}

func Init(sp analytics.SamplePublisher) *Controller {
	ao := &AppResolverOptions{
		failedIpMatchCacheSize:  1024,
		failedDnsMatchCacheSize: 1024,
		apps:                    prodApps,
	}
	c := &Controller{
		AppResolver:            InitAppResolver(ao),
		temporaryRxSpeedTarget: DefaultRxSpeedTarget,
		SamplePublisher:        sp,
		fm:                     make(map[string]*ControllableFlow),
	}
	c.Start()
	return c
}

func (c *Controller) RxSpeedTarget() float64 {
	if c.temporaryTimer != nil {
		return c.temporaryRxSpeedTarget
	}
	return c.settings.BaseRxSpeedTarget
}

func (c *Controller) SetSettings(settings *proxyservice.Settings) {
	log.Printf("set settings: %s", settings)
	c.settings = settings
}

func (c *Controller) setTemporaryRxSpeedTarget(target float64) {
	log.Printf("set rxSpeedTarget: %f", target)
	c.temporaryRxSpeedTarget = target
}

func (c *Controller) SetTemporaryRxSpeedTarget(target float64, duration int) {
	log.Printf("baseRxSpeedTarget: %0.f, temporaryRxSpeedTarget: %0.f, duration: %d", c.settings.BaseRxSpeedTarget, target, duration)
	if target >= 0 {
		c.setTemporaryRxSpeedTarget(target)
	} else {
		c.setTemporaryRxSpeedTarget(math.Inf(1))
	}
	if c.temporaryTimer != nil {
		c.temporaryTimer.Stop()
		c.temporaryTimer = nil
		log.Printf("Pause ended")
	}
	c.temporaryTimer = time.NewTimer(time.Duration(duration) * time.Second)
	go func() {
		<-c.temporaryTimer.C
		c.temporaryTimer = nil
		log.Printf("Pause ended")
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
