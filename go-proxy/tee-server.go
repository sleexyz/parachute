package main

import (
	"fmt"
	"log"
	"net"
	"os"
	"strconv"
	"sync"

	"strange.industries/go-proxy/tunconn"
)

// proxies a packet along
type tee struct {
	i tunconn.TunConn

	oConn    net.Conn
	oAddress string
}

func initTee(i tunconn.TunConn, iport int, oAddress string) (*tee, error) {
	conn, err := net.Dial("udp", oAddress)
	if err != nil {
		return nil, err
	}
	return &tee{i: i, oConn: conn, oAddress: oAddress}, nil
}

func (t *tee) listen() {
	wg := new(sync.WaitGroup)
	wg.Add(2)
	// ctx, cancel := context.WithCancel(context.Background())
	// Inbound messages
	// process client to proxy
	go func() {
		for {
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
			// fmt.Printf("outbound: %s\n", util.MakeDebugString(data[:n]))
		}
		wg.Done()
	}()

	// Outbound messages
	// process proxy back to client
	go func() {
		for {
			data := make([]byte, 1024*4)
			n, err := t.oConn.Read(data)
			if err != nil {
				fmt.Printf("bad read from proxy: %s\n", err)
			}
			_, err = t.i.Write(data[:n])
			if err != nil {
				fmt.Printf("bad write to client: %s\n", err)
			}
			// fmt.Printf("inbound: %s\n", util.MakeDebugString(data[:n]))
		}
		wg.Done()
	}()
	wg.Wait()
	fmt.Println("done waiting")
}

func (t *tee) initOConn() {
	conn, err := net.Dial("udp", t.oAddress)
	if err != nil {
		fmt.Printf("Could not connect %v", err)
		return
	}
	t.oConn = conn
}

const (
	sinkPort = 8082
)

func main() {
	portStr := os.Getenv("PORT")
	if portStr == "" {
		portStr = "8080"
	}
	port, err := strconv.Atoi(portStr)
	if err != nil {
		log.Panicln("could not parse $PORT")
	}

	i1, err := tunconn.InitUDPServerConn(port)
	if err != nil {
		log.Fatalf("Could not initialize internal connection: %v", err)
	}
	defer i1.Close()
	log.Printf("Listening for inbound packets port %s", portStr)

	sink, err := tunconn.InitTCPServerSink(sinkPort)
	if err != nil {
		log.Fatalf("Could not initialize TCPServerSink: %v", err)
	}
	sink.Listen()
	log.Printf("Listening for sink connections at port %v", sinkPort)
	i := tunconn.InitDuplexTee(i1, sink)
	i.WriteLoop()

	// i, err := tunconn.InitWithPcapPipe(i1, "/tmp/goproxy.pcapng")
	// if err != nil {
	// 	log.Fatalf("Could not initialize internal connection: %v", err)
	// }

	const outboundAddress = "0.0.0.0:8081"
	t, err := initTee(i, port, outboundAddress)
	if err != nil {
		log.Fatalf("Could not initialize outbound connection: %v", err)
	}
	log.Printf("Forwarding packets over udp to %s", outboundAddress)
	t.listen()
}
