package controller

import (
	"math"
	"time"

	"strange.industries/go-proxy/pb/proxyservice"
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

type DecisionInfo struct {
	Use    bool
	App    *App
	Reason string
}

type Decision struct {
	*DecisionInfo
	rxSpeedTarget float64
}

func (f *ControllableFlow) makeDecision() *Decision {
	if f.c.sm.ActivePreset().Mode == proxyservice.Mode_FOCUS {
		return f.makeFocusDecision()
	}
	return f.makeProgressiveDecision()
}

func (f *ControllableFlow) makeProgressiveDecision() *Decision {
	di := f.getDecisionInfo()
	if di.Use && di.App != nil {
		return &Decision{rxSpeedTarget: f.c.ProgressiveRxSpeedTarget(), DecisionInfo: di}
	}
	return &Decision{rxSpeedTarget: math.Inf(1), DecisionInfo: di}
}

func (f *ControllableFlow) makeFocusDecision() *Decision {
	di := f.getDecisionInfo()
	if di.Use {
		return &Decision{rxSpeedTarget: f.c.RxSpeedTarget(), DecisionInfo: di}
	}
	return &Decision{rxSpeedTarget: math.Inf(1), DecisionInfo: di}
}

func (f *ControllableFlow) getDecisionInfo() *DecisionInfo {
	appMatch, probability := f.c.GetFuzzyAppMatch(f.ip)
	if appMatch != nil {
		if probability > 0.5 {
			return &DecisionInfo{Use: true, App: appMatch.App, Reason: appMatch.Reason()}
		}
		return &DecisionInfo{Use: false, App: appMatch.App, Reason: appMatch.Reason()}
	}
	return &DecisionInfo{Use: false, Reason: "no match"}
}

func (f *ControllableFlow) InitialSpeed() float64 {
	plan := f.makeDecision()
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
	d := f.makeDecision()
	ctx.Sample.RxSpeedTarget = d.rxSpeedTarget
	ctx.Sample.Ip = f.ip
	ctx.Sample.SlowReason = d.Reason
	ctx.Sample.DnsMatchers = f.c.DebugGetEntries(f.ip)
	if d.App != nil {
		ctx.Sample.AppMatch = d.App.Name()
	}
	return d.rxSpeedTarget
}
