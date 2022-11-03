package forwarder

import (
	"io"
	"log"
	"net"
	"sync"
	"time"

	"strange.industries/go-proxy/adapter"
	"strange.industries/go-proxy/common/pool"
)

var _udpSessionTimeout = 30 * time.Second

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
		// copy packet from uc to pc
		// pc.writeTo(buf[:n], remote)
		if err := copyPacketBuffer(pc, uc, remote, _udpSessionTimeout); err != nil {
			log.Printf("[UDP] %v", err)
		}
	}()

	go func() {
		defer wg.Done()
		// copy packet from pc to uc
		// uc.writeTo(buf[:n], nil)
		if err := copyPacketBuffer(uc, pc, nil, _udpSessionTimeout); err != nil {
			log.Printf("[UDP] %v", err)
		}
	}()

	wg.Wait()
}

func copyPacketBuffer(dst net.PacketConn, src net.PacketConn, to net.Addr, timeout time.Duration) error {
	buf := pool.Get(pool.MaxSegmentSize)
	defer pool.Put(buf)

	for {
		src.SetReadDeadline(time.Now().Add(timeout))
		n, _, err := src.ReadFrom(buf)
		if ne, ok := err.(net.Error); ok && ne.Timeout() {
			return nil /* ignore I/O timeout */
		} else if err == io.EOF {
			return nil /* ignore EOF */
		} else if err != nil {
			return err
		}

		if _, err = dst.WriteTo(buf[:n], to); err != nil {
			return err
		}
		dst.SetReadDeadline(time.Now().Add(timeout))
	}
}
