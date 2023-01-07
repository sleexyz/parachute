package controller

import (
	"math"
	"net/netip"
	"time"

	"strange.industries/go-proxy/pb/proxyservice"
)

type App struct {
	*AppConfig

	// Amount of points of damage taken.
	// Heals towards 0.
	// usagePoints *LinPoints

	// Max txPoints since usagePoints was sampled
	txPointsMax float64
	txPoints    *ExpPoints
	rxPoints    *ExpPoints
}

func InitApps(appConfigs []*AppConfig) []*App {
	apps := []*App{}
	for _, ac := range appConfigs {
		app := InitApp(ac)
		apps = append(apps, app)
	}
	return apps
}

func InitApp(ac *AppConfig) *App {
	app := &App{
		AppConfig:   ac,
		txPointsMax: 0,
		txPoints:    InitExpPoints(math.Pow(0.5, 1.0/5.0), 2),
		rxPoints:    InitExpPoints(math.Pow(0.5, 1.0/5.0), 2),
	}
	return app
}

func (a *App) AppUsed() bool {
	// points > 1
	return a.txPoints.fdate.After(time.Now())
}

// returns new points
func (a *App) AddTxPoints(points float64, now *time.Time) float64 {
	newPoints := a.txPoints.AddPoints(points, now)
	if newPoints > a.txPointsMax {
		a.txPointsMax = newPoints
	}
	return newPoints
}

// returns new points
func (a *App) AddRxPoints(points float64, now *time.Time) float64 {
	return a.rxPoints.AddPoints(points, now)
}

func (a *App) Name() string {
	return a.name
}

func (a *App) MatchByName(name string) float64 {
	for _, r := range a.matchers.dnsMatchers {
		if r.MatchString(name) {
			return 1
		}
	}
	for _, r := range a.matchers.possibleDnsMatchers {
		if r.MatchString(name) {
			return 0.5
		}
	}
	return 0
}

func (a *App) MatchByIp(ip netip.Addr) *netip.Prefix {
	for _, addr := range a.matchers.addresses {
		if addr.Contains(ip) {
			return addr
		}
	}
	return nil
}

func (a *App) RecordState() *proxyservice.AppState {
	s := &proxyservice.AppState{}
	s.Name = a.name
	// now := time.Now()
	// s.UsagePoints = a.usagePoints.Points(&now)
	// s.UsagePointsDate = timestamppb.New(*a.usagePoints.fdate)
	s.TxPoints = a.txPoints.Points()
	s.TxPointsMax = a.txPointsMax
	s.RxPoints = a.rxPoints.Points()
	// s.ProgressiveRxSpeedTarget = a.usagePoints.ProgressiveRxSpeedTarget()
	// log.Printf("ratio: %.2f, speed: %.2f", a.usagePoints.HP()/a.usagePoints.cap, s.ProgressiveRxSpeedTarget)
	return s
}

func (a *App) ResetSampleState() {
	a.txPointsMax = 0
}
