package ffi

import "gvisor.dev/gvisor/pkg/bufferv2"

// Allows outbound packets to
// 1) be written to by a producer, and
// 2) be read from by a consumer
type OutboundChannel struct {
	outbound chan *bufferv2.View
}

func InitOutboundChannel() *OutboundChannel {
	return &OutboundChannel{
		outbound: make(chan *bufferv2.View),
	}
}

func (p *OutboundChannel) WriteOutboundPacket(b []byte) {
	// tee.LogPacket("outbound (write)", b)
	v := bufferv2.NewViewSize(len(b))
	slice := v.AsSlice()
	copy(slice, b)
	p.outbound <- v
}

func (p *OutboundChannel) ReadOutboundPacket() []byte {
	result := <-p.outbound
	defer result.Release()
	return result.AsSlice()
}
