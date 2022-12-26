package controller

import (
	"fmt"
	"math"
	"time"
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
	f.updateTxProvider = f
	return f
}

func (f *ControllableFlow) rxSpeedTarget() (float64, *App, string) {
	app, reason := f.getAppReason()
	if app == nil {
		return math.Inf(1), nil, reason
	}
	return f.RxSpeedTarget(), app, reason
}

func (f *ControllableFlow) getAppReason() (*App, string) {
	appMatch, probability := f.GetFuzzyAppMatch(f.ip)
	if appMatch != nil {
		if probability > 0.5 {
			return appMatch.App, appMatch.Reason()
		} else {
			return nil, fmt.Sprintf("too low: %.2f, correlation: %.2f", probability, Logit(probability))
		}
	}
	return nil, ""
}

func (f *ControllableFlow) InitialSpeed() float64 {
	target, _, _ := f.rxSpeedTarget()
	return target
}

func (f *ControllableFlow) UpdateTx(n int, now time.Time) {
	am := f.GetDefiniteAppMatch(f.ip)
	if am == nil {
		return
	}
	toAdd := 1.0
	_ = am.AddPoints(toAdd, &now)
	// log.Printf("%s points: %.2f, txBytes: %d, reason: %s", am.Name(), points, n, am.Reason())
}

func (f *ControllableFlow) UpdateSpeed(ctx *UpdateRxCtx) float64 {
	f.RecordIp(f.ip)
	st, app, reason := f.rxSpeedTarget()
	ctx.sample.RxSpeedTarget = st
	ctx.sample.Ip = f.ip
	ctx.sample.SlowReason = reason
	ctx.sample.DnsMatchers = f.failedDnsMatchCache.DebugGetEntries(f.ip)
	if app != nil {
		ctx.sample.AppMatch = app.name
	}
	return st
}
