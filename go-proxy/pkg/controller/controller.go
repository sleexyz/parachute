package controller

import (
	"log"
	"math"
	"net"
	"time"
)

const (
	// defaultRxSpeedTarget = 40000.0 // dialup (40kbps)
	DefaultRxSpeedTarget float64 = 100000.0 // 100kbps
)

type FlowData struct {
	IpAddr  net.IP `json:"ipAddr"`
	RxBytes int    `json:"rxBytes"`
	// FirstWrite *time.Time `json:"firstWrite"`
	// LastWrite  *time.Time `json:"lastWrite"`
}

type ControllerSettingsReadOnly interface {
	RxSpeedTarget() float64
}

type ControllerSettingsReadWrite interface {
	ControllerSettingsReadOnly
	RxSpeedTarget() float64
	GetSpeed() *GetSpeedResponse
	SetBaseRxSpeedTarget(target float64)
	SetTemporaryRxSpeedTarget(target float64, seconds int)
}

type Controller struct {
	temporaryRxSpeedTarget float64
	baseRxSpeedTarget      float64
	temporaryTimer         *time.Timer
}

type GetSpeedResponse struct {
	RxSpeedTarget float64 `json:"rxSpeedTarget"`
}

func Init() *Controller {
	return &Controller{
		temporaryRxSpeedTarget: DefaultRxSpeedTarget,
		baseRxSpeedTarget:      DefaultRxSpeedTarget,
	}
}

func (c *Controller) RxSpeedTarget() float64 {
	if c.temporaryTimer != nil {
		return c.temporaryRxSpeedTarget
	}
	return c.baseRxSpeedTarget
}

func (c *Controller) SetBaseRxSpeedTarget(target float64) {
	log.Printf("set baseRxSpeedTarget: %0.f", target)
	c.baseRxSpeedTarget = target
}

func (c *Controller) setTemporaryRxSpeedTarget(target float64) {
	log.Printf("set rxSpeedTarget: %f", target)
	c.temporaryRxSpeedTarget = target
}

func (c *Controller) SetTemporaryRxSpeedTarget(target float64, duration int) {
	log.Printf("baseRxSpeedTarget: %0.f, temporaryRxSpeedTarget: %0.f, duration: %d", c.baseRxSpeedTarget, target, duration)
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

func (c *Controller) GetSpeed() *GetSpeedResponse {
	return &GetSpeedResponse{
		RxSpeedTarget: c.temporaryRxSpeedTarget,
	}
}
