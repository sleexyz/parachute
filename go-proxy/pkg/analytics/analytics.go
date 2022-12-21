package analytics

import (
	"strange.industries/go-proxy/pb/proxyservice"
)

// ingestion
type SamplePublisher interface {
	PublishSample(sample *proxyservice.Sample)
}

type Analytics interface {
	SamplePublisher
	Close()
}

type NoOpAnalytics struct {
}

func (*NoOpAnalytics) Close()                                    {}
func (*NoOpAnalytics) PublishSample(sample *proxyservice.Sample) {}
