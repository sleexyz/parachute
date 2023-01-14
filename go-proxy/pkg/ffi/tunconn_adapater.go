package ffi

// Provides a TunConn
type TunConnAdapter struct {
	cbs Callbacks
	oc  *OutboundChannel
}

func InitTunConnAdapter(cbs Callbacks, oc *OutboundChannel) *TunConnAdapter {
	return &TunConnAdapter{cbs, oc}
}

func (t *TunConnAdapter) Write(b []byte) (int, error) {
	// tee.LogPacket("inbound", b)
	t.cbs.WriteInboundPacket(b)
	return len(b), nil
}

// Read outbound packets
func (t *TunConnAdapter) Read(b []byte) (int, error) {
	packet := t.oc.ReadOutboundPacket()
	// tee.LogPacket("outbound (read)", packet)
	i := copy(b, packet)
	return i, nil
}

func (t *TunConnAdapter) Close() {
}
