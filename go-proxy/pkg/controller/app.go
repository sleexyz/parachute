package controller

import (
	"math"
	"net/netip"
	"time"

	"google.golang.org/protobuf/types/known/timestamppb"
	"strange.industries/go-proxy/pb/proxyservice"
)

type App struct {
	*AppConfig

	sp SettingsProvider

	usagePoints *LinPoints
	// Max txPoints since usagePoints was sampled
	txPointsMax float64
	txPoints    *ExpPoints
	rxPoints    *ExpPoints
}

func InitApps(appConfigs []*AppConfig, sp SettingsProvider) []*App {
	apps := []*App{}
	for _, ac := range appConfigs {
		app := InitApp(ac, sp)
		apps = append(apps, app)
	}
	return apps
}

func InitApp(ac *AppConfig, sp SettingsProvider) *App {
	s := sp.Settings()
	app := &App{
		AppConfig:   ac,
		sp:          sp,
		usagePoints: InitLinPoints(s.UsageHealRate, s.UsageMaxHP),
		txPointsMax: 0,
		txPoints:    InitExpPoints(math.Pow(0.5, 1.0/5.0), 2),
		rxPoints:    InitExpPoints(math.Pow(0.5, 1.0/5.0), 2),
	}
	sp.RegisterChangeListener(app)
	return app
}

func (a *App) BeforeSettingsChange() {
}
func (a *App) OnSettingsChange(oldSettings *proxyservice.Settings, settings *proxyservice.Settings) {
	a.usagePoints.SetHealRate(settings.UsageHealRate)
	a.usagePoints.SetCap(settings.UsageMaxHP)
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
	now := time.Now()
	s.UsagePoints = a.usagePoints.Points(&now)
	s.UsagePointsDate = timestamppb.New(*a.usagePoints.fdate)
	s.TxPoints = a.txPoints.Points()
	s.TxPointsMax = a.txPointsMax
	s.RxPoints = a.rxPoints.Points()
	return s
}

func (a *App) UpdateUsagePoints(dt time.Duration, now *time.Time) {
	if a.txPointsMax >= 1 {
		// Add points at 1 point per minute + lost points due to healing.
		lostPoints := a.usagePoints.DurationToPoints(dt)
		toAdd := float64(dt)/float64(time.Minute) + lostPoints
		a.usagePoints.AddPoints(toAdd, now)
	}
}

func (a *App) ResetSampleState() {
	a.txPointsMax = 0
}
