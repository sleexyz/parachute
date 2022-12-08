package main

import (
	"io"
	"log"

	"strange.industries/go-proxy/pkg/tunconn"
)

// Tees both inbound and outbound packets to a sink.
type DuplexTee struct {
	tunconn.TunConn
	sink io.Writer
	ch   chan []byte
}

func InitDuplexTee(i tunconn.TunConn, sink io.Writer) *DuplexTee {
	ch := make(chan []byte)
	return &DuplexTee{
		TunConn: i,
		sink:    sink,
		ch:      ch,
	}
}

func (i *DuplexTee) WriteLoop() {
	go func() {
		for {
			b := <-i.ch
			_, err := i.sink.Write(b)
			if err != nil {
				log.Printf("error teeing packet: %v\n", err)
			}
		}
	}()
}

func (i *DuplexTee) Write(b []byte) (int, error) {
	n, err := i.TunConn.Write(b)
	if err != nil {
		return n, err
	}
	i.ch <- b
	return n, err
}

func (i *DuplexTee) Read(b []byte) (int, error) {
	n, err := i.TunConn.Read(b)
	if err != nil {
		return n, err
	}
	i.ch <- b
	return n, err
}
