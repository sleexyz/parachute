package controller

import (
	"log"
	"net"
)

type DnsCache interface {
	AddReverseDnsEntry(ip string, name string)
	HasReverseDnsEntry(ip string) bool
	GetReverseDnsEntries(ip string) []string
	LookupIp(ip string)
}

type dnsCache struct {
	// Reverse dns map
	rdnsMap        map[string]map[string]struct{}
	OnEntryUpdater OnEntryUpdater
}

type OnEntryUpdater interface {
	OnEntryUpdate(ip string, name string)
}

func initDnsCache(OnEntryUpdater OnEntryUpdater) DnsCache {
	return &dnsCache{
		rdnsMap:        make(map[string]map[string]struct{}),
		OnEntryUpdater: OnEntryUpdater,
	}
}

func (ar *dnsCache) LookupIp(ip string) {
	// lookup via reverse dns
	names, err := net.LookupAddr(ip)
	if err != nil {
		log.Printf("error looking up ip %s: %v", ip, err)
		return
	}
	for _, name := range names {
		ar.AddReverseDnsEntry(ip, name)
		log.Printf("lookup for ip %s: %v", ip, name)
	}
}

func (ar *dnsCache) HasReverseDnsEntry(ip string) bool {
	_, ok := ar.rdnsMap[ip]
	return ok
}

func (ar *dnsCache) GetReverseDnsEntries(ip string) []string {
	_, ok := ar.rdnsMap[ip]
	if !ok {
		return nil
	}
	var ret []string
	for k := range ar.rdnsMap[ip] {
		ret = append(ret, k)
	}
	return ret
}

func (ar *dnsCache) AddReverseDnsEntry(ip string, name string) {
	if ar.rdnsMap[ip] == nil {
		ar.rdnsMap[ip] = make(map[string]struct{})
	}
	ar.rdnsMap[ip][name] = exists
	ar.OnEntryUpdater.OnEntryUpdate(ip, name)
}
