package internal

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
	"github.com/google/gopacket/pcapgo"
	"golang.org/x/sys/unix"
)

// Creates an internal connection while capturing packets and streaming to a unix pipe.
// Blocking.
type WithPcapPipe struct {
	IConn
	f     *os.File
	pcapw *pcapgo.NgWriter
	ch    chan []byte
}

func InitWithPcapPipe(i IConn, pipeFile string) (*WithPcapPipe, error) {
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
	return &WithPcapPipe{
		IConn: i,
		f:     f,
		pcapw: pcapw,
		ch:    ch,
	}, nil
}

func (i *WithPcapPipe) WriteLoop() {
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

func (i *WithPcapPipe) Close() {
	i.IConn.Close()
	i.f.Close()
}

func (i *WithPcapPipe) writePacket(b []byte) error {
	defer i.pcapw.Flush()
	err := i.pcapw.WritePacket(gopacket.CaptureInfo{
		Timestamp:     time.Now(),
		CaptureLength: len(b),
		Length:        len(b),
	}, b)
	return err
}

func (i *WithPcapPipe) Read(b []byte) (int, error) {
	n, err := i.IConn.Read(b)
	if err != nil {
		return n, err
	}
	i.ch <- b
	return n, nil
}

func (i *WithPcapPipe) Write(b []byte) (int, error) {
	n, err := i.IConn.Write(b)
	if err != nil {
		return n, err
	}
	i.ch <- b
	return n, nil
}
