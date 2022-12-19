// 1) Initializes userTUN.
// 2) Glues TUN and userTUN via Port NAT.

package router

import (
	"context"
	"fmt"
	"io"
	"log"

	"strange.industries/go-proxy/pkg/adapter"
	"strange.industries/go-proxy/pkg/controller"
	"strange.industries/go-proxy/pkg/forwarder"
	"strange.industries/go-proxy/pkg/tunconn"

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
	stack      *stack.Stack
	tcpQueue   chan adapter.TCPConn
	udpQueue   chan adapter.UDPConn
	ep         *channel.Endpoint
	Controller *controller.Controller
}

func Init(address string, i tunconn.TunConn, con *controller.Controller) *Router {
	ep := channel.New(10, defaultMTU, "10.0.0.8")
	tcpQueue := make(chan adapter.TCPConn)
	udpQueue := make(chan adapter.UDPConn)
	s, err := createStack(ep, tcpQueue, udpQueue, con)
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

		// other
		Controller: con,
	}

	return &router
}

func (r *Router) listenInternal(ctx context.Context) {
	childCtx, cancel := context.WithCancel(ctx)
	// forward packet from client to stack
	go func() {
		defer cancel()
		for {
			select {
			case <-childCtx.Done():
				return
			default:
				v := bufferv2.NewViewSize(1024 * 4)
				n, err := r.i.Read(v.AsSlice())
				if err != nil {
					fmt.Printf("(outbound) bad read: %s\n", err)
					return
				}
				if n == 0 {
					continue
				}
				proto := v.AsSlice()[0] >> 4
				pkb := stack.NewPacketBuffer(stack.PacketBufferOptions{
					Payload: bufferv2.MakeWithView(v),
				})
				switch proto {
				case 4:
					r.ep.InjectInbound(ipv4.ProtocolNumber, pkb)
				case 6:
					r.ep.InjectInbound(ipv6.ProtocolNumber, pkb)
				}
				pkb.DecRef()
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
				pkt := r.ep.ReadContext(childCtx)
				if pkt.IsNil() {
					return
				}
				WriteToTUN(pkt, r.i)
			}
		}
	}()
	// <-childCtx.Done()
}

func WriteToTUN(pkt stack.PacketBufferPtr, w io.Writer) tcpip.Error {
	defer pkt.DecRef()
	v := pkt.ToView()
	defer v.Release()
	_, err := w.Write(v.AsSlice())
	if err != nil {
		return &tcpip.ErrInvalidEndpointState{}
	}
	return nil
}

// Initializes channel handlers
func (r *Router) listenExternal(ctx context.Context) {
	defer log.Println("closing external handlers")
	for {
		select {
		case <-ctx.Done():
			return
		case conn := <-r.tcpQueue:
			go forwarder.HandleTCPConn(conn)
		case conn := <-r.udpQueue:
			go forwarder.HandleUDPConn(conn)
		}
	}
}

func (r *Router) Start() {
	ctx, cancel := context.WithCancel(context.Background())
	r.cancel = cancel
	go r.listenExternal(ctx)
	go r.listenInternal(ctx)
	<-ctx.Done()
}

func (r *Router) Close() {
	if r.cancel != nil {
		r.cancel()
	}
}
