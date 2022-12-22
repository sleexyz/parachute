package forwarder

import (
	"io"
	"log"
	"net"
	"sync"
	"time"

	"golang.org/x/net/dns/dnsmessage"
	"gvisor.dev/gvisor/pkg/bufferv2"
	"strange.industries/go-proxy/pkg/adapter"
	"strange.industries/go-proxy/pkg/controller"
)

const (
	// TODO: lower this and see memory performance
	_udpSessionTimeout = 60 * time.Second
	// MaxSegmentSize is the largest possible UDP datagram size.
	// _maxSegmentSize = (64 << 10)
	// _maxSegmentSize = (64 << 10)
	_maxSegmentSize = 1500 // mtu
)

var (
	dnsServerIP = net.ParseIP("10.0.0.9")
)

// var (
// 	inflight       = 0
// 	historicalMaxN = 0 // hmmm. does t seem to exceed mtu size
// )

// uc: connection from
func HandleUDPConn(localConn adapter.UDPConn) {
	defer localConn.Close()
	id := localConn.ID()

	// make actual connection
	targetConn, err := net.ListenPacket("udp", "")
	if err != nil {
		log.Printf("[UDP] dial %s error: %v", id.LocalAddress, err)
		return
	}

	var remote *net.UDPAddr
	if dnsServerIP.Equal(net.IP(id.LocalAddress)) && id.LocalPort == 53 {
		remote = &net.UDPAddr{
			IP:   net.IP{8, 8, 8, 8},
			Port: int(id.LocalPort),
		}
		targetConn = &DnsSnifferConn{PacketConn: targetConn, c: localConn.Controller().DnsCache, IP: &remote.IP}
	} else {
		remote = &net.UDPAddr{
			IP:   net.IP(id.LocalAddress),
			Port: int(id.LocalPort),
		}
		targetConn = &controller.FlowPacketConn{PacketConn: targetConn, S: localConn}
	}

	wg := sync.WaitGroup{}
	wg.Add(2)

	// tx
	go func() {
		defer wg.Done()
		_, err := copyPacketBuffer2(targetConn, localConn, remote, _udpSessionTimeout)
		if err != nil {
			log.Printf("[UDP] %v", err)
		}
	}()

	// rx
	go func() {
		defer wg.Done()
		_, err := copyPacketBuffer2(localConn, targetConn, nil, _udpSessionTimeout)
		if err != nil {
			log.Printf("[UDP] %v", err)
		}
	}()

	wg.Wait()
	localConn.DecRef()
	// _ = time.Since(start)
	// log.Printf("[UDP end (%s) (tx: %d, rx: %d)] %s:%d %s:%d", elapsed, txBytes, rxBytes, id.LocalAddress, id.LocalPort, id.RemoteAddress, id.RemotePort)
}

type DnsSnifferConn struct {
	net.PacketConn
	c  controller.DnsCache
	IP *net.IP
}

func (r *DnsSnifferConn) ReadFrom(buf []byte) (n int, addr net.Addr, err error) {
	n, addr, err = r.PacketConn.ReadFrom(buf)
	{
		err := r.SniffDns(buf)
		if err != nil {
			log.Printf("error parsing dns: %v", err)
		}
	}
	return
}

func (r *DnsSnifferConn) SniffDns(buf []byte) error {
	var p dnsmessage.Parser
	if _, err := p.Start(buf); err != nil {
		return err
	}
	err := p.SkipAllQuestions()
	if err != nil {
		return err
	}
	answers, err := p.AllAnswers()
	if err != nil {
		return err
	}
	for _, a := range answers {
		name := a.Header.Name.String()
		switch m := a.Body.(type) {
		case *dnsmessage.AAAAResource:
			ip := net.IP(m.AAAA[:]).String()

			r.c.AddReverseDnsEntry(ip, name)
		case *dnsmessage.AResource:
			ip := net.IP(m.A[:]).String()
			r.c.AddReverseDnsEntry(ip, name)
		}
	}
	return nil
}

func copyPacketBuffer2(dst net.PacketConn, src net.PacketConn, to net.Addr, timeout time.Duration) (nw int, err error) {
	v := bufferv2.NewViewSize(_maxSegmentSize)
	defer v.Release()

	nw = 0

	for {
		src.SetReadDeadline(time.Now().Add(timeout))
		n, _, err := src.ReadFrom(v.AsSlice())
		nw += n
		if ne, ok := err.(net.Error); ok && ne.Timeout() {
			return nw, nil /* ignore I/O timeout */
		} else if err == io.EOF {
			return nw, nil /* ignore EOF */
		} else if err != nil {
			return nw, err
		}

		if _, err = dst.WriteTo(v.AsSlice()[:n], to); err != nil {
			return nw, err
		}
		dst.SetReadDeadline(time.Now().Add(timeout))
	}
}
