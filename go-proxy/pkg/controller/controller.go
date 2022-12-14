package controller

import (
	"time"

	"strange.industries/go-proxy/pkg/analytics"
)

const (
	defaultTxLatency     = 20
	defaultRxLatency     = 20
	defaultRxSpeedTarget = 50000
)

type Controller struct {
	TxLatency     float64
	RxLatency     float64
	rxSpeedTarget int
	pauseTimer    *time.Timer
	a             *analytics.Analytics
}

type GetSpeedResponse struct {
	TxLatency     float64 `json:"txLatency"`
	RxLatency     float64 `json:"rxLatency"`
	TxSpeed       int     `json:"txSpeed"`
	RxSpeed       int     `json:"rxSpeed"`
	RxSpeedTarget int     `json:"rxSpeedTarget"`
}

func Init(a *analytics.Analytics) *Controller {
	controller := &Controller{
		TxLatency:     defaultTxLatency,
		RxLatency:     defaultRxLatency,
		rxSpeedTarget: defaultRxSpeedTarget,
		a:             a,
	}
	controller.Install()
	return controller
}

// TODO
// - record average tx latency
// - plot graphs
// - goal -- get steady borderline unusable

func (c *Controller) Install() {
	c.a.OnSpeedUpdate = func() {
		delta := c.rxSpeedTarget - c.a.RxSpeed
		dampening := 1 / 10000.0
		if delta > 0 { // under target, breaking connection
			dampening *= 2 // revive it
		}
		c.RxLatency -= float64(delta) * dampening
		c.TxLatency -= float64(delta) * dampening
		if c.RxLatency < 0 {
			c.RxLatency = 0
		}
		if c.TxLatency < 0 {
			c.TxLatency = 0
		}
	}
}

func (c *Controller) Pause() {
	c.rxSpeedTarget = 100000000
	if c.pauseTimer != nil {
		c.pauseTimer.Stop()
	}
	c.pauseTimer = time.NewTimer(time.Minute)
	<-c.pauseTimer.C
	c.rxSpeedTarget = defaultRxSpeedTarget
}

func (c *Controller) GetSpeed() *GetSpeedResponse {
	return &GetSpeedResponse{
		TxLatency:     c.TxLatency,
		RxLatency:     c.RxLatency,
		TxSpeed:       c.a.TxSpeed,
		RxSpeed:       c.a.RxSpeed,
		RxSpeedTarget: c.rxSpeedTarget,
	}
}
