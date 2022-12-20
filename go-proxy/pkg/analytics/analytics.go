package analytics

import (
	"time"
)

// ingestion
type SamplePublisher interface {
	PublishSample(ip string, n int, now time.Time, dt time.Duration)
}

type Analytics interface {
	SamplePublisher
	Close()
}

type NoOpAnalytics struct {
}

func (*NoOpAnalytics) Close()                                                          {}
func (*NoOpAnalytics) PublishSample(ip string, n int, now time.Time, dt time.Duration) {}
