package internal

import (
	"fmt"
	"io"
	"log"
	"net"
	"net/netip"
	"os"
	"time"

	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
	"github.com/google/gopacket/pcapgo"
	"golang.org/x/sys/unix"
)

// Tees both inbound and outbound packets to a sink.
type DuplexTee struct {
	Conn
	sink Sink
	ch   chan []byte
}

func InitDuplexTee(i Conn, sink Sink) *DuplexTee {
	ch := make(chan []byte)
	return &DuplexTee{
		Conn: i,
		sink: sink,
		ch:   ch,
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
	n, err := i.Conn.Write(b)
	if err != nil {
		return n, err
	}
	i.ch <- b
	return n, err
}

func (i *DuplexTee) Read(b []byte) (int, error) {
	n, err := i.Conn.Read(b)
	if err != nil {
		return n, err
	}
	i.ch <- b
	return n, err
}

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

type PcapSink struct {
	f     *os.File
	pcapw *pcapgo.NgWriter
}

func InitPcapSink(pipeFile string) (*PcapSink, error) {
	os.Remove(pipeFile)
	unix.Mkfifo(pipeFile, 0755)
	f, err := os.OpenFile(pipeFile, os.O_RDWR, os.ModeNamedPipe)
	if err != nil {
		return nil, fmt.Errorf("could not open named pipe: %v", err)
	}
	pcapw, err := pcapgo.NewNgWriter(f, layers.LinkTypeRaw)
	if err != nil {
		return nil, fmt.Errorf("could not create pcapw: %v", err)
	}
	return &PcapSink{
		f:     f,
		pcapw: pcapw,
	}, nil
}

func (i *PcapSink) Write(b []byte) error {
	defer i.pcapw.Flush()
	err := i.pcapw.WritePacket(gopacket.CaptureInfo{
		Timestamp:     time.Now(),
		CaptureLength: len(b),
		Length:        len(b),
	}, b)
	return err
}
