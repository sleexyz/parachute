package main

import (
	"fmt"
	"os"
	"time"

	"github.com/google/gopacket"
	"github.com/google/gopacket/layers"
	"github.com/google/gopacket/pcapgo"
	"golang.org/x/sys/unix"
)

type PcapSink struct {
	f     *os.File
	pcapw *pcapgo.NgWriter
}

func initPcapSink(pipeFile string) (*PcapSink, error) {
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
