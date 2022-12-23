package controller

import (
	"fmt"
	"log"
	"math"
	"net/netip"

	"strange.industries/go-proxy/pb/proxyservice"
)

var exists = struct{}{}

type AppMatch struct {
	*App

	prefix  *netip.Prefix
	dnsName string

	correlationScore int
	inferred         bool
}

func (am *AppMatch) Reason() string {
	if am.inferred {
		return fmt.Sprintf("inferred (%s), correlation: %d", am.Name(), am.correlationScore)
	}
	if am.prefix != nil {
		return am.prefix.String()
	}
	if am.dnsName != "" {
		return am.dnsName
	}
	return "invalid reason"
}

func Logistic(x float64) float64 {
	return 0.5 + math.Tanh(x/2)/2
}

func Logit(x float64) float64 {
	return math.Log(x / (1 - x))
}

func (am *AppMatch) Probability() float64 {
	if am.inferred {
		return Logistic(float64(am.correlationScore))
	}
	return 1
}

type AppResolver struct {
	DnsCache DnsCache
	apps     []*App

	// Whether an ip should map to an app
	appMap         map[string]*AppMatch
	inferredAppMap map[string]*AppMatch

	// Whether match has been attempted
	lookupCache map[string]struct{}
}

func InitAppResolver() *AppResolver {
	ar := &AppResolver{
		apps:           apps,
		appMap:         make(map[string]*AppMatch),
		inferredAppMap: make(map[string]*AppMatch),
		lookupCache:    make(map[string]struct{}),
	}
	ar.DnsCache = initDnsCache(ar)
	return ar
}

func (ar *AppResolver) OnEntryUpdate(ip string, name string) {
	// update app map
	_, ok := ar.appMap[ip]
	if ok {
		return
	}
	for _, app := range ar.apps {
		p := app.MatchByName(name)
		if p == 1 {
			ar.appMap[ip] = &AppMatch{App: app, dnsName: name}
			// log.Printf("registered matching ip: %s, %s, via %s", ip, app, name)
			return
		} else if p == 0.5 {
			ar.inferredAppMap[ip] = &AppMatch{App: app, dnsName: name, inferred: true, correlationScore: 0}
		}
	}
}

// Attempt ip match and lookup once per ip
// TODO: add a TTL to lookupCache
func (ar *AppResolver) RegisterIp(ip string) {
	_, ok := ar.lookupCache[ip]
	if !ok && !ar.DnsCache.HasReverseDnsEntry(ip) {
		go func() {
			am := ar.matchAppByIp(ip)
			if am != nil {
				ar.appMap[ip] = am
				log.Printf("registered matching ip: %s, %s", ip, am.name)
				return
			}
			ar.DnsCache.LookupIp(ip)
			ar.lookupCache[ip] = exists
		}()
	}
}

func (ar *AppResolver) matchAppByIp(ip string) *AppMatch {
	addr := netip.MustParseAddr(ip)
	for _, app := range ar.apps {
		prefix := app.MatchByIp(addr)
		if prefix != nil {
			return &AppMatch{App: app, prefix: prefix}
		}
	}
	return nil
}

func (ar *AppResolver) RecordIp(ip string) {
	_, ok := ar.appMap[ip]
	if ok {
		return
	}
	match, ok := ar.inferredAppMap[ip]
	app := ar.AppUsed()
	if ok && app == match.App {
		ar.inferredAppMap[ip].correlationScore += 1
		return
	}
	if ok {
		ar.inferredAppMap[ip].correlationScore -= 1
		return
	}
}

func (ar *AppResolver) GetDefiniteAppMatch(ip string) *AppMatch {
	return ar.appMap[ip]
}

func (ar *AppResolver) GetFuzzyAppMatch(ip string) (*AppMatch, float64) {
	match, ok := ar.appMap[ip]
	if ok {
		return match, 1
	}
	match, ok = ar.inferredAppMap[ip]
	if ok {
		return match, match.Probability()
	}
	return nil, 0
}

func (ar *AppResolver) AppUsed() *App {
	for _, app := range ar.apps {
		if app.AppUsed() {
			return app
		}
	}
	return nil
}

func (ar *AppResolver) RecordState() *proxyservice.ServerState {
	s := &proxyservice.ServerState{}
	for _, app := range ar.apps {
		s.Apps = append(s.Apps, app.RecordState())
	}
	return s
}
