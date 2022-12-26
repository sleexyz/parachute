package controller

import (
	"fmt"
	"math"
	"net/netip"
)

type AppMatch struct {
	*App

	prefix  *netip.Prefix
	dnsName string

	correlationScore int
	inferred         bool
}

func (am *AppMatch) Reason() string {
	if am.inferred {
		return fmt.Sprintf("inferred (%s), correlation: %d", am.Name(), am.correlationScore)
	}
	if am.prefix != nil {
		return am.prefix.String()
	}
	if am.dnsName != "" {
		return am.dnsName
	}
	return "invalid reason"
}

func Logistic(x float64) float64 {
	return 0.5 + math.Tanh(x/2)/2
}

func Logit(x float64) float64 {
	return math.Log(x / (1 - x))
}

func (am *AppMatch) Probability() float64 {
	if am.inferred {
		return Logistic(float64(am.correlationScore))
	}
	return 1
}
