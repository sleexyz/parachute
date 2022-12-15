package forwarder

import (
	"io"
	"log"
	"net"
	"sync"
	"time"

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

	remote := &net.UDPAddr{
		IP:   net.IP(id.LocalAddress),
		Port: int(id.LocalPort),
	}

	// var txBytes int
	// var rxBytes int
	start := time.Now()
	// log.Printf("[UDP start] %s:%d %s:%d", id.LocalAddress, id.LocalPort, id.RemoteAddress, id.RemotePort)
	wg := sync.WaitGroup{}
	wg.Add(2)

	go func() {
		defer wg.Done()
		_, err := copyPacketBuffer2(targetConn, localConn, remote, _udpSessionTimeout)
		if err != nil {
			log.Printf("[UDP] %v", err)
		}
		// txBytes = n
	}()

	go func() {
		defer wg.Done()
		slowedTargetConn := &controller.SlowablePacketConn{PacketConn: targetConn, S: localConn.Slowable()}
		_, err := copyPacketBuffer2(localConn, slowedTargetConn, nil, _udpSessionTimeout)
		if err != nil {
			log.Printf("[UDP] %v", err)
		}
		// rxBytes = n
	}()

	wg.Wait()
	_ = time.Since(start)
	// log.Printf("[UDP end (%s) (tx: %d, rx: %d)] %s:%d %s:%d", elapsed, txBytes, rxBytes, id.LocalAddress, id.LocalPort, id.RemoteAddress, id.RemotePort)
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
