package controller

import (
	"math"
	"time"

	"strange.industries/go-proxy/pkg/controller/flow"
)

type ControllableFlow struct {
	*flow.SpeedControlledFlow
	c  *Controller
	ip string
}

func InitControllableFlow(c *Controller, ip string) *ControllableFlow {
	f := &ControllableFlow{
		c:  c,
		ip: ip,
	}
	f.SpeedControlledFlow = flow.InitSpeedControlledFlow(c, f)
	f.UpdateTxProvider = f
	return f
}

type plan struct {
	rxSpeedTarget float64
	app           *App
	reason        string
}

func (f *ControllableFlow) makePlan() *plan {
	appMatch, probability := f.c.GetFuzzyAppMatch(f.ip)
	if appMatch != nil {
		if probability > 0.5 {
			return &plan{rxSpeedTarget: f.c.RxSpeedTarget(), app: appMatch.App, reason: appMatch.Reason()}
		}
		return &plan{rxSpeedTarget: math.Inf(1), app: appMatch.App, reason: appMatch.Reason()}
	}
	return &plan{rxSpeedTarget: math.Inf(1), reason: "no match"}
}

func (f *ControllableFlow) InitialSpeed() float64 {
	plan := f.makePlan()
	return plan.rxSpeedTarget
}

func (f *ControllableFlow) UpdateTx(n int, now time.Time) {
	am := f.c.GetDefiniteAppMatch(f.ip)
	if am != nil {
		_ = am.AddTxPoints(1.0, &now)
	}
	// log.Printf("%s points: %.2f, txBytes: %d, reason: %s", am.Name(), points, n, am.Reason())
}

func (f *ControllableFlow) UpdateSpeed(ctx *flow.UpdateRxCtx) float64 {
	am := f.c.GetDefiniteAppMatch(f.ip)
	if am != nil {
		_ = am.AddRxPoints(1.0, ctx.Now)
	}
	f.c.RecordIp(f.ip)
	plan := f.makePlan()
	ctx.Sample.RxSpeedTarget = plan.rxSpeedTarget
	ctx.Sample.Ip = f.ip
	ctx.Sample.SlowReason = plan.reason
	ctx.Sample.DnsMatchers = f.c.DebugGetEntries(f.ip)
	if plan.app != nil {
		ctx.Sample.AppMatch = plan.app.Name()
	}
	return plan.rxSpeedTarget
}
