package controller

import (
	"log"
	"net/netip"
)

var exists = struct{}{}

type AppResolver struct {
	DnsCache DnsCache
	apps     []*App

	// Whether an ip should map to an app
	appMap map[string]string

	// Whether match has been attempted
	lookupCache map[string]struct{}
}

func InitAppResolver() *AppResolver {
	ar := &AppResolver{
		apps:        apps,
		appMap:      make(map[string]string),
		lookupCache: make(map[string]struct{}),
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
	app := ar.matchAppByName(name)
	if app != "" {
		ar.appMap[ip] = app
		// log.Printf("registered matching ip: %s, %s, via %s", ip, app, name)
	}
}

// Attempt ip match and lookup once per ip
// TODO: add a TTL to lookupCache
func (ar *AppResolver) RegisterIp(ip string) {
	_, ok := ar.lookupCache[ip]
	if !ok && !ar.DnsCache.HasReverseDnsEntry(ip) {
		go func() {
			app := ar.matchAppByIp(ip)
			if app != "" {
				ar.appMap[ip] = app
				log.Printf("registered matching ip: %s, %s", ip, app)
				return
			}
			ar.DnsCache.LookupIp(ip)
			ar.lookupCache[ip] = exists
		}()
	}

	// lookup via configuration
}

func (ar *AppResolver) matchAppByName(name string) string {
	for _, app := range ar.apps {
		if app.MatchByName(name) {
			return app.name
		}
	}
	return ""
}

func (ar *AppResolver) matchAppByIp(ip string) string {
	addr := netip.MustParseAddr(ip)
	for _, app := range ar.apps {
		if app.MatchByIp(addr) {
			return app.name
		}
	}
	return ""
}

func (ar *AppResolver) HasMatch(ip string) bool {
	_, ok := ar.appMap[ip]
	return ok
}
