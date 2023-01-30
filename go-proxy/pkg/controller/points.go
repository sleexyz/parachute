package controller

import (
	"log"
	"math"
)

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

func (p *Points) LogDelta(oldValue float64) {
	delta := p.value - oldValue
	if delta < 0 {
		log.Printf("Healed %.2f hp", math.Abs(delta))
	}
	if delta > 0 {
		log.Printf("Took %.2f damage", math.Abs(delta))
	}
}

func (p *Points) Points() float64 {
	return p.value
}

func (p *Points) HP() float64 {
	return p.cap - p.value
}

func (p *Points) CapDamage(damage float64) {
	p.value = math.Min(damage, p.value)
}

func (p *Points) HealTo(hpMin float64) {
	// Cannot have more damage than cap - targetHP
	p.CapDamage(p.cap - hpMin)
}
