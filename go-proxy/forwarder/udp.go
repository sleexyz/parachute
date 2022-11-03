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
	_udpSessionTimeout = 10 * time.Second
	// MaxSegmentSize is the largest possible UDP datagram size.
	_maxSegmentSize = (1 << 16) - 1
)

var inflight = 0

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
		// copy outbound packet from uc to pc
		// pc.writeTo(buf[:n], remote)
		if err := copyPacketBuffer2(pc, uc, remote, _udpSessionTimeout); err != nil {
			log.Printf("[UDP] %v", err)
		}
	}()

	go func() {
		defer wg.Done()
		// copy inbound packet from pc to uc
		// uc.writeTo(buf[:n], nil)
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
	i := 0
	inflight++
	defer func() {
		duration := time.Since(start)
		log.Printf("inflight: %d, iterations: %d, elapsed: %s\n", inflight, i, duration)
		inflight--
	}()
	for {
		i++
		src.SetReadDeadline(time.Now().Add(timeout))
		n, _, err := src.ReadFrom(v.AsSlice())
		if ne, ok := err.(net.Error); ok && ne.Timeout() {
			return nil /* ignore I/O timeout */
		} else if err == io.EOF {
			return nil /* ignore EOF */
		} else if err != nil {
			return err
		}

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
