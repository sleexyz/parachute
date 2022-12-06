package forwarder

import (
	"context"
	"io"
	"log"
	"net"
	"sync"
	"time"

	"gvisor.dev/gvisor/pkg/bufferv2"
	"strange.industries/go-proxy/adapter"
	"strange.industries/go-proxy/dialer"
	M "strange.industries/go-proxy/metadata"
)

const (
	tcpWaitTimeout     = 5 * time.Second
	tcpKeepAlivePeriod = 30 * time.Second
	tcpConnectTimeout  = 5 * time.Second

	_relayBufferSize = 16 << 10
)

// setKeepAlive sets tcp keepalive option for tcp connection.
func setKeepAlive(c net.Conn) {
	if tcp, ok := c.(*net.TCPConn); ok {
		tcp.SetKeepAlive(true)
		tcp.SetKeepAlivePeriod(tcpKeepAlivePeriod)
	}
}

func DialContext(ctx context.Context, metadata *M.Metadata) (net.Conn, error) {
	c, err := dialer.DialContext(ctx, "tcp", metadata.DestinationAddress())
	if err != nil {
		return nil, err
	}
	setKeepAlive(c)
	return c, nil
}

func Dial(metadata *M.Metadata) (net.Conn, error) {
	ctx, cancel := context.WithTimeout(context.Background(), tcpConnectTimeout)
	defer cancel()
	return DialContext(ctx, metadata)
}

func HandleTCPConn(localConn adapter.TCPConn) {
	defer localConn.Close()

	id := localConn.ID()
	metadata := &M.Metadata{
		Network: M.TCP,
		SrcIP:   net.IP(id.RemoteAddress),
		SrcPort: id.RemotePort,
		DstIP:   net.IP(id.LocalAddress),
		DstPort: id.LocalPort,
	}

	targetConn, err := Dial(metadata)
	if err != nil {
		log.Printf("[TCP] dial %s error: %v", metadata.DestinationAddress(), err)
		return
	}
	metadata.MidIP, metadata.MidPort = parseAddr(targetConn.LocalAddr())

	defer targetConn.Close()

	// log.Printf("[TCP] %s <-> %s\n", metadata.SourceAddress(), metadata.DestinationAddress())
	relay(localConn, targetConn) /* relay connections */
}

// relay copies between left and right bidirectionally.
func relay(left, right net.Conn) {
	wg := sync.WaitGroup{}
	wg.Add(2)

	go func() {
		defer wg.Done()
		_ = copyBuffer(right, left) /* ignore error */
		right.SetReadDeadline(time.Now().Add(tcpWaitTimeout))
	}()

	go func() {
		defer wg.Done()
		_ = copyBuffer(left, right) /* ignore error */
		left.SetReadDeadline(time.Now().Add(tcpWaitTimeout))
	}()

	wg.Wait()
}

func copyBuffer(dst io.Writer, src io.Reader) error {
	v := bufferv2.NewViewSize(_relayBufferSize)
	defer v.Release()

	_, err := io.CopyBuffer(dst, src, v.AsSlice())
	return err
}
