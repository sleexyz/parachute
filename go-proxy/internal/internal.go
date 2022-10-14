package internal

import (
	"fmt"
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

type IConn interface {
	Write(b []byte) (int, error)
	Read(b []byte) (int, error)
}

type UDPIConn struct {
	conn    *net.UDPConn
	udpAddr *net.UDPAddr
}

func InitUDPIConn(port int) (*UDPIConn, error) {
	conn, err := net.ListenUDP("udp", &net.UDPAddr{IP: netip.MustParseAddr("0.0.0.0").AsSlice(), Port: port})
	if err != nil {
		return nil, err
	}
	return &UDPIConn{
		conn: conn,
	}, nil
}

func (i *UDPIConn) Close() {
	i.conn.Close()
}

func (i *UDPIConn) Read(b []byte) (int, error) {
	n, addr, err := i.conn.ReadFromUDP(b)
	if addr != nil {
		i.udpAddr = addr
	}
	return n, err
}

func (i *UDPIConn) Write(b []byte) (int, error) {
	if i.udpAddr == nil {
		return 0, fmt.Errorf("error: downstream UDP connection not initialized")
	}
	return i.conn.WriteTo(b, i.udpAddr)
}

type UdpIConnWithPcapPipe struct {
	UDPIConn
	f     *os.File
	pcapw *pcapgo.NgWriter
	ch    chan []byte
}

func InitUDPIConnWithPcapPipe(port int, pipeFile string) (*UdpIConnWithPcapPipe, error) {
	i, err := InitUDPIConn(port)
	if err != nil {
		return nil, err
	}
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

	ch := make(chan []byte)
	return &UdpIConnWithPcapPipe{
		UDPIConn: *i,
		f:        f,
		pcapw:    pcapw,
		ch:       ch,
	}, nil
}

func (i *UdpIConnWithPcapPipe) WriteLoop() {
	go func() {
		for {
			b := <-i.ch
			err := i.writePacket(b)
			if err != nil {
				log.Printf("(pcap): error writing pcap packet: %v\n", err)
			}
		}
	}()
}

func (i *UdpIConnWithPcapPipe) Close() {
	i.UDPIConn.Close()
	i.f.Close()
}

func (i *UdpIConnWithPcapPipe) writePacket(b []byte) error {
	defer i.pcapw.Flush()
	err := i.pcapw.WritePacket(gopacket.CaptureInfo{
		Timestamp:     time.Now(),
		CaptureLength: len(b),
		Length:        len(b),
	}, b)
	return err
}

func (i *UdpIConnWithPcapPipe) Read(b []byte) (int, error) {
	n, err := i.UDPIConn.Read(b)
	if err != nil {
		return n, err
	}
	i.ch <- b
	return n, nil
}

func (i *UdpIConnWithPcapPipe) Write(b []byte) (int, error) {
	n, err := i.UDPIConn.Write(b)
	if err != nil {
		return n, err
	}
	i.ch <- b
	return n, nil
}
