package analytics

import (
	"net"
	"sort"
	"sync"
	"time"

	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
)

var (
	routerIpv4Addr = net.ParseIP("10.0.0.8")
	routerIpv6Addr = net.ParseIP("fd00::2")
)

const (
	cleanupInterval = 1 * time.Minute
)

// TODO: regularly evict old values

type Analytics struct {
	flows         map[string]*Flow
	mut           *sync.RWMutex
	cleanupTicker *time.Ticker
	cleanupQuit   chan (struct{})
}

func Init() *Analytics {
	analytics := &Analytics{
		flows: make(map[string]*Flow),
		mut:   &sync.RWMutex{},
	}
	analytics.Start()
	return analytics
}

func (a *Analytics) Close() {
	close(a.cleanupQuit)
}

func (a *Analytics) Start() {
	a.cleanupTicker = time.NewTicker(cleanupInterval)
	a.cleanupQuit = make(chan struct{})
	go func() {
		for {
			select {
			case <-a.cleanupTicker.C:
				a.clearOldFlows()
				// do stuff
			case <-a.cleanupQuit:
				a.cleanupTicker.Stop()
				return
			}
		}
	}()
}

type Flow struct {
	IpAddr     net.IP     `json:"ipAddr"`
	TxBytes    int        `json:"txBytes"`
	RxBytes    int        `json:"rxBytes"`
	FirstWrite *time.Time `json:"firstWrite"`
	LastWrite  *time.Time `json:"lastWrite"`
}

func (a *Analytics) clearOldFlows() {
	a.mut.Lock()
	defer a.mut.Unlock()
	deadline := time.Now().Add(-1 * cleanupInterval)
	for key, flow := range a.flows {
		if flow == nil {
			continue
		}
		if flow.LastWrite.Before(deadline) {
			delete(a.flows, key)
		}
	}
}

func (a *Analytics) GetRecentFlows() []Flow {
	a.mut.RLock()
	defer a.mut.RUnlock()
	flows := []Flow{}
	i := 0
	for _, value := range a.flows {
		flows = append(flows, *value)
		i += 1
	}
	sort.SliceStable(flows, func(i, j int) bool {
		return flows[i].LastWrite.After(*flows[j].LastWrite)
	})
	return flows
}

func (a *Analytics) ProcessPacket(b []byte) {
	if len(b) == 0 {
		return
	}
	ipVersion := (b[0] & 0xf0) >> 4
	var packet gopacket.Packet
	if ipVersion == 6 {
		packet = gopacket.NewPacket(b, layers.LayerTypeIPv6, gopacket.Default)
	} else {
		packet = gopacket.NewPacket(b, layers.LayerTypeIPv4, gopacket.Default)
	}
	var ipAddr net.IP
	isTx := true
	if ipv4Layer := packet.Layer(layers.LayerTypeIPv4); ipv4Layer != nil {
		ipv4, _ := ipv4Layer.(*layers.IPv4)
		if routerIpv4Addr.Equal(ipv4.SrcIP) {
			ipAddr = ipv4.DstIP
			isTx = true
		} else if routerIpv4Addr.Equal(ipv4.DstIP) {
			ipAddr = ipv4.SrcIP
			isTx = false
		} else {
			// log.Printf("Received irrelevant packet: %s -> %s", ipv4.SrcIP.String(), ipv4.DstIP.String())
			return
		}
	}
	if ipv6Layer := packet.Layer(layers.LayerTypeIPv6); ipv6Layer != nil {
		ipv6, _ := ipv6Layer.(*layers.IPv6)
		if routerIpv6Addr.Equal(ipv6.SrcIP) {
			ipAddr = ipv6.DstIP
			isTx = true
		} else if routerIpv6Addr.Equal(ipv6.DstIP) {
			ipAddr = ipv6.SrcIP
			isTx = false
		} else {
			// log.Printf("Received irrelevant packet: %s -> %s", ipv6.SrcIP.String(), ipv6.DstIP.String())
			return
		}
	}

	a.mut.Lock()
	defer a.mut.Unlock()

	// log.Printf("Processing packet from %s to %s", srcIP.String(), dstIP.String())
	key := ipAddr.String()

	flow := a.flows[key]
	if flow == nil {
		flow = &Flow{}
	}
	flow.IpAddr = ipAddr

	if isTx {
		flow.TxBytes += len(b)
	} else {
		flow.RxBytes += len(b)
	}
	if flow.FirstWrite == nil {
		firstWrite := time.Now()
		flow.FirstWrite = &firstWrite
	}
	lastWrite := time.Now()
	flow.LastWrite = &lastWrite
	a.flows[key] = flow
}
