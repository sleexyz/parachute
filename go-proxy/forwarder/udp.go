package forwarder

import (
	"io"
	"log"
	"net"
	"sync"
	"time"

	"gvisor.dev/gvisor/pkg/bufferv2"
	"strange.industries/go-proxy/adapter"
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
	inflight       = 0
	historicalMaxN = 0 // hmmm. does t seem to exceed mtu size
)

// uc: connection from
func HandleUDPConn(uc adapter.UDPConn) {
	defer uc.Close()
	id := uc.ID()

	// make actual connection
	pc, err := net.ListenPacket("udp", "")
	if err != nil {
		log.Printf("[UDP] dial %s error: %v", id.LocalAddress, err)
		return
	}

	remote := &net.UDPAddr{
		IP:   net.IP(id.LocalAddress),
		Port: int(id.LocalPort),
	}

	wg := sync.WaitGroup{}
	wg.Add(2)

	go func() {
		defer wg.Done()
		if err := copyPacketBuffer2(pc, uc, remote, _udpSessionTimeout); err != nil {
			log.Printf("[UDP] %v", err)
		}
	}()

	go func() {
		defer wg.Done()
		if err := copyPacketBuffer2(uc, pc, nil, _udpSessionTimeout); err != nil {
			log.Printf("[UDP] %v", err)
		}
	}()

	wg.Wait()
}

func copyPacketBuffer2(dst net.PacketConn, src net.PacketConn, to net.Addr, timeout time.Duration) error {
	v := bufferv2.NewViewSize(_maxSegmentSize)
	defer v.Release()

	start := time.Now()
	br := 0
	i := 0
	maxN := 0
	inflight++
	defer func() {
		duration := time.Since(start)
		avg := -1
		if i > 0 {
			avg = br / i
		}
		if maxN > historicalMaxN {
			historicalMaxN = maxN
		}
		log.Printf("inflight: %d, historicalMaxN: %d, bytes read: %d, iterations: %d, avg bytes per iteration: %d, max bytes per iteration: %d, elapsed: %s\n", inflight, historicalMaxN, br, i, avg, maxN, duration)
		inflight--
	}()
	for {
		src.SetReadDeadline(time.Now().Add(timeout))
		n, _, err := src.ReadFrom(v.AsSlice())
		if ne, ok := err.(net.Error); ok && ne.Timeout() {
			log.Println("timeout")
			return nil /* ignore I/O timeout */
		} else if err == io.EOF {
			log.Println("eof")
			return nil /* ignore EOF */
		} else if err != nil {
			return err
		}
		br += n
		if n > maxN {
			maxN = n
		}
		i++

		if _, err = dst.WriteTo(v.AsSlice()[:n], to); err != nil {
			return err
		}
		dst.SetReadDeadline(time.Now().Add(timeout))
	}
}

// func copyPacketBuffer(dst net.PacketConn, src net.PacketConn, to net.Addr, timeout time.Duration) error {
// 	buf := pool.Get(pool.MaxSegmentSize)
// 	defer pool.Put(buf)

// 	for {
// 		src.SetReadDeadline(time.Now().Add(timeout))
// 		n, _, err := src.ReadFrom(buf)
// 		if ne, ok := err.(net.Error); ok && ne.Timeout() {
// 			return nil /* ignore I/O timeout */
// 		} else if err == io.EOF {
// 			return nil /* ignore EOF */
// 		} else if err != nil {
// 			return err
// 		}

// 		if _, err = dst.WriteTo(buf[:n], to); err != nil {
// 			return err
// 		}
// 		dst.SetReadDeadline(time.Now().Add(timeout))
// 	}
// }
