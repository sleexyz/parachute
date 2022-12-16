package controller

import (
	"log"
	"math"
	"net"
	"time"
)

const (
	// defaultRxSpeedTarget = 40000.0 // dialup (40kbps)
	defaultRxSpeedTarget = 100000.0 // 100kbps
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
	rxSpeedTarget     float64
	baseRxSpeedTarget float64
	temporaryTimer    *time.Timer
}

type GetSpeedResponse struct {
	RxSpeedTarget float64 `json:"rxSpeedTarget"`
}

func Init() *Controller {
	controller := &Controller{
		rxSpeedTarget:     defaultRxSpeedTarget,
		baseRxSpeedTarget: defaultRxSpeedTarget,
	}
	return controller
}

func (c *Controller) RxSpeedTarget() float64 {
	return c.rxSpeedTarget
}

func (c *Controller) SetRxSpeedTarget(target float64) {
	c.baseRxSpeedTarget = target
}

func (c *Controller) SetTemporaryRxSpeedTarget(target float64, duration int) {
	log.Printf("target: %0.f, duration: %d", target, duration)
	if target >= 0 {
		c.rxSpeedTarget = target
	} else {
		c.rxSpeedTarget = math.Inf(1)
	}
	if c.temporaryTimer != nil {
		c.temporaryTimer.Stop()
		log.Printf("Pause ended")
	}
	c.temporaryTimer = time.NewTimer(time.Duration(duration) * time.Second)
	go func() {
		<-c.temporaryTimer.C
		c.rxSpeedTarget = c.baseRxSpeedTarget
	}()
}

func (c *Controller) GetSpeed() *GetSpeedResponse {
	return &GetSpeedResponse{
		RxSpeedTarget: c.rxSpeedTarget,
	}
}
