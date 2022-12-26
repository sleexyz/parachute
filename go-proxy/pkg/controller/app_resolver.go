package controller

import (
	"log"
	"net"
	"net/netip"

	"strange.industries/go-proxy/pb/proxyservice"
)

var exists = struct{}{}

type AppResolver struct {
	apps []*App

	// Whether an ip should map to an app
	appMap         map[string]*AppMatch
	inferredAppMap map[string]*AppMatch

	failedIpMatchCache  *LRUCache[struct{}]
	failedDnsMatchCache *DnsMatchCache
}

type AppResolverOptions struct {
	failedIpMatchCacheSize  int
	failedDnsMatchCacheSize int
	apps                    []*App
}

func InitAppResolver(options *AppResolverOptions) *AppResolver {
	ar := &AppResolver{
		apps:                options.apps,
		appMap:              make(map[string]*AppMatch),
		inferredAppMap:      make(map[string]*AppMatch),
		failedIpMatchCache:  InitLRUCache[struct{}](options.failedIpMatchCacheSize),
		failedDnsMatchCache: initDnsMatchCache(options.failedDnsMatchCacheSize),
	}
	return ar
}

// Registers a dns entry
func (ar *AppResolver) RegisterDnsEntry(ip string, name string) {
	// if ip already matches, continue
	match := ar.checkAppMatch(ip)
	if match {
		return
	}
	ar.checkDnsMatch(ip, name)
}

func (ar *AppResolver) checkAppMatch(ip string) bool {
	_, ok := ar.appMap[ip]
	if ok {
		return true
	}
	_, ok = ar.inferredAppMap[ip]
	if ok {
		return true
	}
	return false
}

func (ar *AppResolver) checkDnsMatch(ip string, name string) {
	ok := ar.failedDnsMatchCache.HasEntry(ip, name)
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
			return
		}
	}
	ar.failedDnsMatchCache.AddEntry(ip, name)
}

func (ar *AppResolver) RegisterIp(ip string) {
	match := ar.checkAppMatch(ip)
	if match {
		return
	}
	ar.checkIpMatch(ip)
	ar.lookupUnknownIp(ip)
}

func (ar *AppResolver) checkIpMatch(ip string) {
	if ar.failedIpMatchCache.Has(ip) {
		return
	}
	am := ar.matchAppByIp(ip)
	if am != nil {
		ar.appMap[ip] = am
		log.Printf("registered matching ip: %s, %s", ip, am.name)
		return
	}
	ar.failedIpMatchCache.Put(ip, exists)
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

func (ar *AppResolver) lookupUnknownIp(ip string) {
	if ar.failedDnsMatchCache.Has(ip) {
		return
	}
	// Only do dns lookup when app signal is firing
	app := ar.AppUsed()
	if app == nil {
		return
	}
	go func() {
		// lookup via reverse dns
		names, err := net.LookupAddr(ip)
		if err != nil {
			log.Printf("error looking up ip %s: %v", ip, err)
			return
		}
		for _, name := range names {
			ar.RegisterDnsEntry(ip, name)
			log.Printf("lookup for ip %s: %v", ip, name)
		}
	}()
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
