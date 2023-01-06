package flow

import (
	"time"
)

type Flow interface {
	RecordTxBytes(n int, now time.Time)
	RecordRxBytes(n int, now time.Time)
	InjectRxLatency(n int)
	DecRef()
	IncRef()
}
