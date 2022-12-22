package controller

import (
	"math"
)

type ControllableFlow struct {
	*SpeedControlledFlow
	*Controller
	ip string
}

func InitControllableFlow(c *Controller, ip string) *ControllableFlow {
	f := &ControllableFlow{
		Controller: c,
		ip:         ip,
	}
	f.SpeedControlledFlow = InitSpeedControlledFlow(c, f)
	return f
}

func (f *ControllableFlow) rxSpeedTarget() float64 {
	if f.GetApp(f.ip) != nil {
		return math.Inf(1)
	}
	return f.RxSpeedTarget()
}

func (f *ControllableFlow) InitialSpeed() float64 {
	return f.rxSpeedTarget()
}

func (f *ControllableFlow) UpdateSpeed(ctx *UpdateCtx) float64 {
	st := f.rxSpeedTarget()
	ctx.sample.Ip = f.ip
	app := f.GetApp(f.ip)
	if app != nil {
		ctx.sample.AppMatch = app.name
	}
	ctx.sample.RxSpeedTarget = st
	return st
}
