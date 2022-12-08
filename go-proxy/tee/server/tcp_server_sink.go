package main

import (
	"io"
	"log"
	"net"
	"net/netip"
)

type TCPServerSink struct {
	l    *net.TCPListener
	conn net.Conn
}

func InitTCPServerSink(port int) (*TCPServerSink, error) {
	l, err := net.ListenTCP("tcp", &net.TCPAddr{IP: netip.MustParseAddr("0.0.0.0").AsSlice(), Port: port})
	if err != nil {
		return nil, err
	}
	return &TCPServerSink{
		l: l,
	}, nil
}

func (i *TCPServerSink) Listen() {
	go func() {
		for {
			conn, err := i.l.Accept()
			log.Println("Sink client accepted")
			if err != nil {
				log.Printf("error: %v\n", err)
			}
			i.conn = conn
			one := make([]byte, 1)
			for {
				if _, err := conn.Read(one); err == io.EOF {
					break
				}
			}
			conn.Close()
			i.conn = nil
			log.Println("Sink client closed")
		}
	}()
}

func (i *TCPServerSink) Write(b []byte) (int, error) {
	if i.conn == nil {
		return 0, nil
	}
	n, err := i.conn.Write(b)
	if err != nil {
		log.Printf("error: %v\n", err)
		return 0, nil
	}
	return n, nil
}
