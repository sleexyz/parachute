package controller

import "math"

// Damage points
type Points struct {
	cap   float64
	value float64
}

func InitPoints(cap float64) *Points {
	return &Points{cap: cap}
}

func (p *Points) SetCap(cap float64) {
	p.cap = cap
}

func (p *Points) AddPoints(points float64) float64 {
	p.value = math.Max(math.Min(points+p.value, p.cap), 0)
	return p.value
}

func (p *Points) Points() float64 {
	return p.value
}

func (p *Points) HP() float64 {
	return p.cap - p.value
}

func (p *Points) ProgressiveRxSpeedTarget() float64 {
	ratio := p.HP() / p.cap
	if ratio < 1.0/6.0 {
		return 50e3
	}
	if ratio < 2.0/6.0 {
		return 100e3
	}
	if ratio < 3.0/6.0 {
		return 200e3
	}
	return math.Inf(1)
}