package controller

import (
	"time"
)

type Flow interface {
	Update(n int, now time.Time)
	InjectRxLatency(n int)
	DecRef()
	IncRef()
}
