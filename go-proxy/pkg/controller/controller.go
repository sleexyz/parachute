package controller

import (
	"log"
	"math"
	"net"
	"time"
)

const (
	// defaultRxSpeedTarget = 40000.0 // dialup (40kbps)
	defaultRxSpeedTarget = 400000.0 // 400kbps
)

type FlowData struct {
	IpAddr  net.IP `json:"ipAddr"`
	RxBytes int    `json:"rxBytes"`
	// FirstWrite *time.Time `json:"firstWrite"`
	// LastWrite  *time.Time `json:"lastWrite"`
}

type ControllerSettingsReadonly interface {
	RxSpeedTarget() float64
}

type Controller struct {
	rxSpeedTarget float64
	pauseTimer    *time.Timer
}

type GetSpeedResponse struct {
	RxSpeedTarget float64 `json:"rxSpeedTarget"`
}

func Init() *Controller {
	controller := &Controller{
		rxSpeedTarget: defaultRxSpeedTarget,
	}
	return controller
}

func (c *Controller) RxSpeedTarget() float64 {
	return c.rxSpeedTarget
}

func (c *Controller) Pause() {
	c.rxSpeedTarget = math.Inf(1)
	if c.pauseTimer != nil {
		c.pauseTimer.Stop()
		log.Printf("Pause ended")
	}
	c.pauseTimer = time.NewTimer(time.Minute)
	<-c.pauseTimer.C
	c.rxSpeedTarget = defaultRxSpeedTarget
}

func (c *Controller) GetSpeed() *GetSpeedResponse {
	return &GetSpeedResponse{
		RxSpeedTarget: c.rxSpeedTarget,
	}
}
