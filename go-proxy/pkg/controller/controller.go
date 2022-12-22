package controller

import (
	"context"
	"log"
	"math"
	"net"
	"net/netip"
	"regexp"
	"time"

	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/analytics"
)

const (
	// defaultRxSpeedTarget = 40000.0 // dialup (40kbps)
	DefaultRxSpeedTarget float64 = 100000.0 // 100kbps
)

type ControllerSettingsReadOnly interface {
	RxSpeedTarget() float64
	UseExponentialDecay() bool
}

type ControllerSettingsReadWrite interface {
	ControllerSettingsReadOnly
	ResetPoints()
	SetSettings(settings *proxyservice.Settings)
	SetTemporaryRxSpeedTarget(target float64, seconds int)
}

type Controller struct {
	analytics.SamplePublisher
	settings               *proxyservice.Settings
	temporaryRxSpeedTarget float64
	temporaryTimer         *time.Timer
	fm                     map[string]*ControllableFlow
	// Reverse dns map
	rdnsMap map[string]map[string]struct{}
	// Whether an ip should map to an app
	appMap map[string]string
	// Whether an ip lookup has been attempted
	lookupCache  map[string]struct{}
	gcTicker     *time.Ticker
	stopGcTicker func()
}

func Init(sp analytics.SamplePublisher) *Controller {
	c := &Controller{
		temporaryRxSpeedTarget: DefaultRxSpeedTarget,
		SamplePublisher:        sp,
		fm:                     make(map[string]*ControllableFlow),
		rdnsMap:                make(map[string]map[string]struct{}),
		appMap:                 make(map[string]string),
		lookupCache:            make(map[string]struct{}),
	}
	c.Start()
	return c
}

var exists = struct{}{}

type AppRule struct {
	dnsMatchers []*regexp.Regexp
	addresses   []*netip.Prefix
}

var appMatchers = map[string]*AppRule{
	"tiktok": {
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
			regexp.MustCompile(`.*\.static\.akamaitechnologies\.com\.$`),
		},
	},
	"instagram": {
		dnsMatchers: []*regexp.Regexp{
			regexp.MustCompile(`.*\.instagram\.com\.$`),
			regexp.MustCompile(`.*\.cdninstagram\.com\.$`),
			regexp.MustCompile(`.*\.fbcdn\.net\.$`),
			regexp.MustCompile(`.*\.facebook\.com\.$`),
		},
	},
	"twitter": {
		dnsMatchers: []*regexp.Regexp{
			regexp.MustCompile(`.*\.twitter\.com\.$`),
			regexp.MustCompile(`.*\.twitter\.map\.fastly\.net\.$`),
			regexp.MustCompile(`.*\.cloudfront\.net\.$`),
			regexp.MustCompile(`.*\.edgecastcdn\.net\.$`),
		},
		addresses: append(
			// fastly
			ParseAddresses([]string{"23.235.32.0/20", "43.249.72.0/22", "103.244.50.0/24", "103.245.222.0/23", "103.245.224.0/24", "104.156.80.0/20", "140.248.64.0/18", "140.248.128.0/17", "146.75.0.0/17", "151.101.0.0/16", "157.52.64.0/18", "167.82.0.0/17", "167.82.128.0/20", "167.82.160.0/20", "167.82.224.0/20", "172.111.64.0/18", "185.31.16.0/22", "199.27.72.0/21", "199.232.0.0/16"}),
			// twitter
			ParseAddresses([]string{"104.244.42.0/24"})...,
		),
	},
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

func (c *Controller) ShouldSlow(ip string) bool {
	_, ok := c.appMap[ip]
	return ok
}

func (c *Controller) matchAppByName(name string) string {
	for appName, appEntry := range appMatchers {
		for _, r := range appEntry.dnsMatchers {
			if r.MatchString(name) {
				return appName
			}
		}
	}
	return ""
}

func (c *Controller) matchAppByIp(ip string) string {
	addr := netip.MustParseAddr(ip)
	for appName, appEntry := range appMatchers {
		for _, a := range appEntry.addresses {
			if a.Contains(addr) {
				return appName
			}
		}
	}
	return ""
}

func (c *Controller) AddReverseDnsEntry(ip string, name string) {
	if c.rdnsMap[ip] == nil {
		c.rdnsMap[ip] = make(map[string]struct{})
	}
	c.rdnsMap[ip][name] = exists

	// update app map
	_, ok := c.appMap[ip]
	if ok {
		return
	}
	app := c.matchAppByName(name)
	if app != "" {
		c.appMap[ip] = app
		// log.Printf("registered matching ip: %s, %s, via %s", ip, app, name)
	}
}

func (c *Controller) HasReverseDnsEntry(ip string) bool {
	_, ok := c.rdnsMap[ip]
	return ok
}

func (c *Controller) GetReverseDnsEntry(ip string) []string {
	_, ok := c.rdnsMap[ip]
	if !ok {
		return nil
	}
	var ret []string
	for k := range c.rdnsMap[ip] {
		ret = append(ret, k)
	}
	return ret
}

func (c *Controller) UseExponentialDecay() bool {
	return c.settings.UseExponentialDecay
}

func (c *Controller) RxSpeedTarget() float64 {
	if c.temporaryTimer != nil {
		return c.temporaryRxSpeedTarget
	}
	return c.settings.BaseRxSpeedTarget
}

func (c *Controller) SetSettings(settings *proxyservice.Settings) {
	log.Printf("set settings: %s", settings)
	c.settings = settings
}

func (c *Controller) setTemporaryRxSpeedTarget(target float64) {
	log.Printf("set rxSpeedTarget: %f", target)
	c.temporaryRxSpeedTarget = target
}

func (c *Controller) SetTemporaryRxSpeedTarget(target float64, duration int) {
	log.Printf("baseRxSpeedTarget: %0.f, temporaryRxSpeedTarget: %0.f, duration: %d", c.settings.BaseRxSpeedTarget, target, duration)
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

func (c *Controller) LookupIp(ip string) {
	// lookup via configuration
	app := c.matchAppByIp(ip)
	if app != "" {
		c.appMap[ip] = app
		log.Printf("registered matching ip: %s, %s", ip, app)
		return
	}

	// lookup via reverse dns
	names, err := net.LookupAddr(ip)
	if err != nil {
		log.Printf("error looking up ip %s: %v", ip, err)
		return
	}
	for _, name := range names {
		c.AddReverseDnsEntry(ip, name)
		log.Printf("lookup for ip %s: %v", ip, name)
	}
}

func (c *Controller) GetFlow(ip string) *ControllableFlow {
	if _, ok := c.fm[ip]; !ok {
		c.fm[ip] = InitControllableFlow(c, ip)
		_, ok := c.lookupCache[ip]
		if !c.HasReverseDnsEntry(ip) && !ok {
			go func() {
				c.LookupIp(ip)
				c.lookupCache[ip] = exists
			}()
		}
	}
	f := c.fm[ip]
	f.IncRef()
	return f
}

func (c *Controller) Start() {
	c.gcTicker = time.NewTicker(1 * time.Minute)
	ctx, cancel := context.WithCancel(context.Background())
	c.stopGcTicker = func() {
		c.gcTicker.Stop()
		cancel()
	}
	go func() {
		for {
			select {
			case <-ctx.Done():
				return
			case <-c.gcTicker.C:
				c.GarbageCollect()
			}
		}
	}()
}

func (c *Controller) Close() {
	c.stopGcTicker()
}

func (c *Controller) GarbageCollect() {
	// now := time.Now()
	log.Printf("garbage collection started")
	for k, v := range c.fm {
		if v != nil && v.refCount == 0 {
			log.Printf("deleting %s", c.fm[k].ip)
			delete(c.fm, k)
		}
	}
}

func (c *Controller) ResetPoints() {
	for k := range c.fm {
		delete(c.fm, k)
	}
}
