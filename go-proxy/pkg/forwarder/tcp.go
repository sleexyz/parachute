package forwarder

import (
	"context"
	"errors"
	"io"
	"log"
	"net"
	"sync"
	"syscall"
	"time"

	"gvisor.dev/gvisor/pkg/bufferv2"
	"strange.industries/go-proxy/pkg/adapter"
	"strange.industries/go-proxy/pkg/controller"
)

const (
	tcpWaitTimeout     = 30 * time.Second
	tcpKeepAlivePeriod = 30 * time.Second
	tcpConnectTimeout  = 30 * time.Second

	// _relayBufferSize = 16 << 10
	_relayBufferSize = 16 << 10
	//_relayBufferSize = 1024 * 2
)

// setKeepAlive sets tcp keepalive option for tcp connection.
func setKeepAlive(c net.Conn) {
	if tcp, ok := c.(*net.TCPConn); ok {
		tcp.SetKeepAlive(true)
		tcp.SetKeepAlivePeriod(tcpKeepAlivePeriod)
	}
}

func DialContext(ctx context.Context, dstAddr string) (net.Conn, error) {
	d := &net.Dialer{}
	c, err := d.DialContext(ctx, "tcp", dstAddr)
	if err != nil {
		return nil, err
	}
	setKeepAlive(c)
	return c, nil
}

func Dial(dstAddr string) (net.Conn, error) {
	ctx, cancel := context.WithTimeout(context.Background(), tcpConnectTimeout)
	defer cancel()
	return DialContext(ctx, dstAddr)
}

func HandleTCPConn(localConn adapter.TCPConn) {
	defer localConn.Close()

	id := localConn.ID()
	metadata := &metadata{
		SrcIP:   net.IP(id.RemoteAddress),
		SrcPort: id.RemotePort,
		DstIP:   net.IP(id.LocalAddress),
		DstPort: id.LocalPort,
	}

	startTime := time.Now()
	// log.Printf("[TCP start] %s <-> %s\n", metadata.SourceAddress(), metadata.DestinationAddress())
	targetConn, err := Dial(metadata.DestinationAddress())
	if err != nil {
		log.Printf("[TCP] dial %s error: %v", metadata.DestinationAddress(), err)
		return
	}
	metadata.MidIP, metadata.MidPort = parseAddr(targetConn.LocalAddr())

	defer targetConn.Close()

	slowedTargetConn := &controller.FlowConn{Conn: targetConn, S: localConn}
	_, _ = relay(localConn, slowedTargetConn) /* relay connections */
	_ = time.Since(startTime)
	localConn.DecRef()
	// log.Printf("[TCP end (%s) (tx: %d, rx: %d)] %s <-> %s\n", elapsed, txBytes, rxBytes, metadata.SourceAddress(), metadata.DestinationAddress())
}

// relay copies between left and right bidirectionally.
func relay(localConn adapter.TCPConn, targetConn net.Conn) (int64, int64) {

	var txBytes int64
	var rxBytes int64
	wg := sync.WaitGroup{}
	wg.Add(2)

	go func() {
		defer wg.Done()
		txBytes, _ = copyBuffer(targetConn, localConn) /* ignore error */
		targetConn.SetReadDeadline(time.Now().Add(tcpWaitTimeout))
	}()

	go func() {
		defer wg.Done()
		rxBytes, _ = copyBuffer(localConn, targetConn) /* ignore error */
		localConn.SetReadDeadline(time.Now().Add(tcpWaitTimeout))
	}()

	wg.Wait()
	return txBytes, rxBytes
}

func copyBuffer(dst io.Writer, src io.Reader) (int64, error) {
	v := bufferv2.NewViewSize(_relayBufferSize)
	defer v.Release()

	n, err := io.CopyBuffer(dst, src, v.AsSlice())

	if ne, ok := err.(net.Error); ok && ne.Timeout() {
		return n, nil /* ignore I/O timeout */
	} else if errors.Is(err, syscall.EPIPE) {
		return n, nil /* ignore broken pipe */
	} else if errors.Is(err, syscall.ECONNRESET) {
		return n, nil /* ignore connection reset by peer */
	}
	return n, err
}
