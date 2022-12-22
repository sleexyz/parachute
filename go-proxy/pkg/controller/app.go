package controller

import (
	"net/netip"
	"regexp"
)

type AppMatcher struct {
	dnsMatchers []*regexp.Regexp
	addresses   []*netip.Prefix
}

var apps = []*App{
	InitApp("tiktok", &AppMatcher{
		dnsMatchers: []*regexp.Regexp{
			regexp.MustCompile(`.*bytedance\.map\.fastly\.net\.$`),
			regexp.MustCompile(`.*\.tiktokcdn-us\.com\.c\.footprint\.net\.$`),
			regexp.MustCompile(`.*\.byteoversea\.net\.$`),
			regexp.MustCompile(`.*\.bytefcdn-oversea\.com\.$`),
			regexp.MustCompile(`.*\.ttoverseaus\.net\.$`),
			regexp.MustCompile(`.*\.bytetcdn\.com\.$`),
			regexp.MustCompile(`.*\.cdn77\.org\.$`),
			regexp.MustCompile(`.*\.akamai\.net\.$`),
			regexp.MustCompile(`.*\.worldfcdn\.com\.$`),
			regexp.MustCompile(`.*\.worldfcdn2\.com\.$`),
			regexp.MustCompile(`.*\.akamaiedge\.net\.$`),
			// TODO: disable
			regexp.MustCompile(`.*\.static\.akamaitechnologies\.com\.$`),
		},
	}),
	InitApp("instagram", &AppMatcher{
		dnsMatchers: []*regexp.Regexp{
			regexp.MustCompile(`.*\.instagram\.com\.$`),
			regexp.MustCompile(`.*\.cdninstagram\.com\.$`),
			regexp.MustCompile(`.*\.fbcdn\.net\.$`),
			regexp.MustCompile(`.*\.facebook\.com\.$`),
		},
	}),
	InitApp("twitter", &AppMatcher{
		dnsMatchers: []*regexp.Regexp{
			regexp.MustCompile(`.*\.twitter\.com\.$`),
			regexp.MustCompile(`.*\.twitter\.map\.fastly\.net\.$`),
			// TODO: disable
			regexp.MustCompile(`.*\.cloudfront\.net\.$`),
			regexp.MustCompile(`.*\.edgecastcdn\.net\.$`),
		},
		addresses: append(
			// fastly
			ParseAddresses([]string{"23.235.32.0/20", "43.249.72.0/22", "103.244.50.0/24", "103.245.222.0/23", "103.245.224.0/24", "104.156.80.0/20", "140.248.64.0/18", "140.248.128.0/17", "146.75.0.0/17", "151.101.0.0/16", "157.52.64.0/18", "167.82.0.0/17", "167.82.128.0/20", "167.82.160.0/20", "167.82.224.0/20", "172.111.64.0/18", "185.31.16.0/22", "199.27.72.0/21", "199.232.0.0/16"}),
			// twitter
			ParseAddresses([]string{"104.244.42.0/24"})...,
		),
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
	matchers *AppMatcher
	name     string
}

func InitApp(name string, matchers *AppMatcher) *App {
	return &App{name: name, matchers: matchers}
}

func (a *App) Name() string {
	return a.name
}

func (a *App) MatchByName(name string) bool {
	for _, r := range a.matchers.dnsMatchers {
		if r.MatchString(name) {
			return true
		}
	}
	return false
}

func (a *App) MatchByIp(ip netip.Addr) bool {
	for _, addr := range a.matchers.addresses {
		if addr.Contains(ip) {
			return true
		}
	}
	return false
}
