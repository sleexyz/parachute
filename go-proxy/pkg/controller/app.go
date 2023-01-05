package controller

import (
	"math"
	"net/netip"
	"regexp"
	"time"

	"google.golang.org/protobuf/types/known/timestamppb"
	"strange.industries/go-proxy/pb/proxyservice"
)

type AppMatcher struct {
	dnsMatchers         []*regexp.Regexp
	possibleDnsMatchers []*regexp.Regexp
	addresses           []*netip.Prefix
}

var prodApps = []*App{
	InitApp("tiktok", &AppMatcher{
		dnsMatchers: []*regexp.Regexp{
			regexp.MustCompile(`.*bytedance\.map\.fastly\.net\.$`),
			regexp.MustCompile(`.*\.tiktokcdn-us\.com\.c\.footprint\.net\.$`),
			regexp.MustCompile(`.*\.byteoversea\.net\.$`),
			regexp.MustCompile(`.*\.bytefcdn-oversea\.com\.$`),
			regexp.MustCompile(`.*\.ttoverseaus\.net\.$`),
			regexp.MustCompile(`.*\.bytetcdn\.com\.$`),
			regexp.MustCompile(`.*\.worldfcdn\.com\.$`),
			regexp.MustCompile(`.*\.worldfcdn2\.com\.$`),
		},
		possibleDnsMatchers: []*regexp.Regexp{
			regexp.MustCompile(`.*\.cdn77\.org\.$`),
			regexp.MustCompile(`.*\.akamai\.net\.$`),
			regexp.MustCompile(`.*\.akamaiedge\.net\.$`),
			regexp.MustCompile(`.*\.static\.akamaitechnologies\.com\.$`),
		},
	}),
	InitApp("instagram", &AppMatcher{
		dnsMatchers: []*regexp.Regexp{
			regexp.MustCompile(`.*\.instagram\.com\.$`),
			regexp.MustCompile(`.*\.cdninstagram\.com\.$`),
			regexp.MustCompile(`instagram.*\.fbcdn\.net\.$`),
			// regexp.MustCompile(`.*\.facebook\.com\.$`),
		},
	}),
	InitApp("twitter", &AppMatcher{
		dnsMatchers: []*regexp.Regexp{
			regexp.MustCompile(`t\.co\.$`),
			regexp.MustCompile(`.*\.twitter\.com\.$`),
			regexp.MustCompile(`.*\.twitter\.map\.fastly\.net\.$`),
		},
		possibleDnsMatchers: []*regexp.Regexp{
			regexp.MustCompile(`.*\.cloudfront\.net\.$`),
			regexp.MustCompile(`.*\.edgecastcdn\.net\.$`),
		},
		addresses: ParseAddresses([]string{"104.244.42.0/24"}),
		// addresses: append(
		// 	// fastly
		// 	ParseAddresses([]string{"23.235.32.0/20", "43.249.72.0/22", "103.244.50.0/24", "103.245.222.0/23", "103.245.224.0/24", "104.156.80.0/20", "140.248.64.0/18", "140.248.128.0/17", "146.75.0.0/17", "151.101.0.0/16", "157.52.64.0/18", "167.82.0.0/17", "167.82.128.0/20", "167.82.160.0/20", "167.82.224.0/20", "172.111.64.0/18", "185.31.16.0/22", "199.27.72.0/21", "199.232.0.0/16"}),
		// 	// twitter
		// 	ParseAddresses([]string{"104.244.42.0/24"})...,
		// ),
	}),
}

func ParseAddresses(strs []string) []*netip.Prefix {
	var ret []*netip.Prefix
	for _, s := range strs {
		p, err := netip.ParsePrefix(s)
		if err != nil {
			panic(err)
		}
		ret = append(ret, &p)
	}
	return ret
}

type App struct {
	matchers    *AppMatcher
	name        string
	usagePoints *LinPoints
	// Max txPoints since usagePoints was sampled
	txPointsMax float64
	txPoints    *ExpPoints
	rxPoints    *ExpPoints
}

func InitApp(name string, matchers *AppMatcher) *App {
	return &App{
		name:     name,
		matchers: matchers,
		// TODO: get this from a controller setting
		// Setting:
		// - Duration (e.g. 5min)
		// - Healing duration (e.g. 10min)
		//
		//
		usagePoints: InitLinPoints(0.5, 6, 0),
		txPointsMax: 0,
		txPoints:    InitExpPoints(math.Pow(0.5, 1.0/5.0), 2),
		rxPoints:    InitExpPoints(math.Pow(0.5, 1.0/5.0), 2),
	}
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
	a.txPointsMax = 0
}
