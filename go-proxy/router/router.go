// 1) Initializes userTUN.
// 2) Glues TUN and userTUN via Port NAT.

package router

import (
	"context"
	"fmt"
	"log"

	"strange.industries/go-proxy/adapter"
	"strange.industries/go-proxy/external"
	"strange.industries/go-proxy/forwarder"
	"strange.industries/go-proxy/tunconn"
	"strange.industries/go-proxy/util"

	"gvisor.dev/gvisor/pkg/bufferv2"
	"gvisor.dev/gvisor/pkg/tcpip"
	"gvisor.dev/gvisor/pkg/tcpip/link/channel"
	"gvisor.dev/gvisor/pkg/tcpip/network/ipv4"
	"gvisor.dev/gvisor/pkg/tcpip/network/ipv6"
	"gvisor.dev/gvisor/pkg/tcpip/stack"
)

const (
	defaultMTU = 1500
)

type Router struct {
	cancel func()

	// internal (device <=> proxy)
	i tunconn.TunConn

	// external (proxy <=> internet)
	stack    *stack.Stack
	tcpQueue chan adapter.TCPConn
	udpQueue chan adapter.UDPConn
	ep       *channel.Endpoint
}

func Init(address string, i tunconn.TunConn) *Router {
	ep := channel.New(10, defaultMTU, "10.0.0.8")
	tcpQueue := make(chan adapter.TCPConn)
	udpQueue := make(chan adapter.UDPConn)

	// With high mtu, low packet loss and low latency over tuntap,
	// the specific value isn't that important. The only important
	// bit is that it should be at least a couple times MSS.
	bufSize := 4 * 1024 * 1024

	s, err := external.CreateStack(ep, tcpQueue, udpQueue, bufSize, bufSize)
	if err != nil {
		log.Panicln(err)
	}

	router := Router{
		// external
		stack:    s,
		tcpQueue: tcpQueue,
		udpQueue: udpQueue,
		ep:       ep,

		// internal
		i: i,
	}

	return &router
}

func (c *Router) listenInternal(ctx context.Context) {
	defer log.Println("closing internal handlers")
	childCtx, cancel := context.WithCancel(ctx)
	// forward packet from client to stack
	go func() {
		defer cancel()
		for {
			select {
			case <-childCtx.Done():
				return
			default:
				data := make([]byte, 1024*4)
				n, err := c.i.Read(data)
				if err != nil {
					fmt.Printf("(outbound) bad read: %s\n", err)
					return
				}
				_, err = c.WriteToStack(data[:n])
				if err != nil {
					fmt.Printf("(outbound) bad write: %s\n", err)
					return
				}
			}
		}
	}()
	// forward packet from stack to client
	go func() {
		defer cancel()
		for {
			select {
			case <-childCtx.Done():
				return
			default:
				pkt := c.ep.ReadContext(childCtx)
				if pkt.IsNil() {
					return
				}
				c.WriteInboundPacket(pkt)
			}
		}
	}()
	<-childCtx.Done()
}

func (c *Router) WriteInboundPacket(pkt stack.PacketBufferPtr) tcpip.Error {
	defer pkt.DecRef()
	buf := pkt.ToBuffer()
	defer buf.Release()
	data := buf.Flatten()
	debugString := util.MakeDebugString(data)
	_, err := c.i.Write(data)
	if err != nil {
		fmt.Printf("(inbound) %s, error:%s\n", debugString, err)
		return &tcpip.ErrInvalidEndpointState{}
	}
	return nil
}

func (c *Router) WriteToStack(b []byte) (int, error) {
	if len(b) == 0 {
		return 0, nil
	}
	pkb := stack.NewPacketBuffer(stack.PacketBufferOptions{
		Payload: bufferv2.MakeWithData(b),
	})
	switch b[0] >> 4 {
	case 4:
		c.ep.InjectInbound(ipv4.ProtocolNumber, pkb)
	case 6:
		c.ep.InjectInbound(ipv6.ProtocolNumber, pkb)
	}
	pkb.DecRef()
	return len(b), nil
}

// Initializes channel handlers
func (c *Router) listenExternal(ctx context.Context) {
	defer log.Println("closing external handlers")
	for {
		select {
		case <-ctx.Done():
			return
		case conn := <-c.tcpQueue:
			go forwarder.HandleTCPConn(conn)
		case conn := <-c.udpQueue:
			go forwarder.HandleUDPConn(conn)
		}
	}
}

func (c *Router) Start() {
	ctx, cancel := context.WithCancel(context.Background())
	c.cancel = cancel
	go c.listenExternal(ctx)
	go c.listenInternal(ctx)
}

func (c *Router) Close() {
	if c.cancel != nil {
		c.cancel()
	}
}
