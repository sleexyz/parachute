package main

import (
	"log"
	"net"
	"os/exec"

	"strange.industries/go-proxy/tunconn"
	"strange.industries/go-proxy/util"
)

const (
	sinkAddress = "0.0.0.0:8082"
	pcapFile    = "/tmp/goproxy.pcapng"
)

func main() {
	pcapSink, err := tunconn.InitPcapSink(pcapFile)
	if err != nil {
		log.Panicf("could not create pcap sink: %v\n", err)
	}
	log.Printf("created pcap sink at %s\n", pcapFile)

	cmd := exec.Command("/Applications/Wireshark.app/Contents/MacOS/Wireshark", "-k", "-i", pcapFile)
	go func() {
		err = cmd.Run()
		if err != nil {
			log.Panicf("could not initialize wireshark: %v\n", err)
		}
	}()

	for {
		conn, err := net.Dial("tcp", sinkAddress)
		if err != nil {
			log.Printf("error: %s\n", err)
		}
		log.Printf("accepted connection to %s\n", sinkAddress)
		for {
			data := make([]byte, 1024*4)
			n, err := conn.Read(data)
			if err != nil {
				log.Printf("error reading: %v\n", err)
				break
			}
			str := util.MakeDebugString(data[:n])
			log.Println(str)
			err = pcapSink.Write(data[:n])
			if err != nil {
				log.Printf("error reading: %v\n", err)
			}
		}
	}
}
