package tee

import (
	"context"
	"fmt"
	"net"

	"strange.industries/go-proxy/tunconn"
	"strange.industries/go-proxy/util"
)

// proxies a packet along
type Tee struct {
	i tunconn.TunConn

	oConn    net.Conn
	oAddress string
	cancel   func()
}

func InitTee(i tunconn.TunConn, oAddress string) (*Tee, error) {
	conn, err := net.Dial("udp", oAddress)
	if err != nil {
		return nil, err
	}
	return &Tee{i: i, oConn: conn, oAddress: oAddress}, nil
}

func (t *Tee) Listen() {
	childCtx, cancel := context.WithCancel(context.Background())
	t.cancel = cancel
	// Inbound messages
	// process client to proxy
	go func() {
		defer cancel()
		for {
			select {
			case <-childCtx.Done():
				return
			default:
				data := make([]byte, 1024*4)
				n, err := t.i.Read(data)
				if err != nil {
					fmt.Printf("bad read from client: %s\n", err)
					// TODO: close
					return
				}
				if t.oConn != nil {
					_, err = t.oConn.Write(data[:n])
					if err != nil {
						fmt.Printf("bad write to client: %s\n", err)
					}
				}
				fmt.Println(util.MakeDebugString(data[:n]))
			}
		}
	}()

	// Outbound messages
	// process proxy back to client
	go func() {
		for {
			select {
			case <-childCtx.Done():
				return
			default:
				data := make([]byte, 1024*4)
				n, err := t.oConn.Read(data)
				if err != nil {
					fmt.Printf("bad read from proxy: %s\n", err)
					continue
				}
				_, err = t.i.Write(data[:n])
				if err != nil {
					fmt.Printf("bad write to client: %s\n", err)
					continue
				}
				// fmt.Printf("inbound: %s\n", util.MakeDebugString(data[:n]))
			}
		}
	}()

	<-childCtx.Done()
}

func (c *Tee) Close() {
	if c.cancel != nil {
		c.cancel()
	}
}
