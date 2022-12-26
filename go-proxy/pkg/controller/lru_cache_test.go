package controller

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestCapacity1(t *testing.T) {
	l := InitLRUCache[int](1)
	l.Put("hello", 1)
	assert.True(t, l.Has("hello"))
	l.Put("world", 2)
	assert.False(t, l.Has("hello"), "expected eviction")
	assert.True(t, l.Has("world"))
}

func TestCapacity3(t *testing.T) {
	l := InitLRUCache[int](3)
	l.Put("1", 1)
	l.Put("2", 2)
	l.Put("3", 3)
	l.Put("4", 4)
	assert.False(t, l.Has("1"), "expected eviction")
	assert.True(t, l.Has("2"))
	assert.True(t, l.Has("3"))
	assert.True(t, l.Has("4"))
}

func TestExistingAdd(t *testing.T) {
	l := InitLRUCache[int](3)
	l.Put("1", 1)
	l.Put("2", 2)
	l.Put("3", 3)

	l.Put("1", 1)

	l.Put("4", 4)
	assert.False(t, l.Has("2"), "expected eviction")

	l.Put("2", 2)

	l.Put("5", 5)
	assert.False(t, l.Has("3"), "expected eviction")
}

func TestReplacement(t *testing.T) {
	l := InitLRUCache[int](1)
	l.Put("1", 1)
	l.Put("1", 2)
	val, _ := l.Get("1")
	assert.Equal(t, val, 2, "expected replacement")
}
