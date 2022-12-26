package controller

var dcexists = struct{}{}

type DnsMatchCache struct {
	// Reverse dns map
	rdnsMap *LRUCache[map[string]struct{}]
}

func initDnsMatchCache(capacity int) *DnsMatchCache {
	return &DnsMatchCache{
		rdnsMap: InitLRUCache[map[string]struct{}](capacity),
	}
}

func (d *DnsMatchCache) Has(ip string) bool {
	return d.rdnsMap.Has(ip)
}

func (d *DnsMatchCache) HasEntry(ip string, name string) bool {
	entries, ok := d.rdnsMap.Get(ip)
	if ok {
		_, ok := entries[name]
		return ok
	}
	return false
}

func (d *DnsMatchCache) DebugGetEntries(ip string) []string {
	entries, ok := d.rdnsMap.Get(ip)
	if !ok {
		return nil
	}
	var ret []string
	for k := range entries {
		ret = append(ret, k)
	}
	return ret
}

func (d *DnsMatchCache) AddEntry(ip string, name string) {
	if _, ok := d.rdnsMap.Get(ip); !ok {
		d.rdnsMap.Put(ip, make(map[string]struct{}))
	}
	val, _ := d.rdnsMap.Get(ip)
	val[name] = dcexists
}
