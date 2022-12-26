package controller

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestWithoutEviction(t *testing.T) {
	l := initDnsMatchCache(1)
	l.AddEntry("192.168.1.1", "hello.com")
	assert.True(t, l.Has("192.168.1.1"))
	assert.True(t, l.HasEntry("192.168.1.1", "hello.com"))
	entries := l.DebugGetEntries("192.168.1.1")
	assert.Len(t, entries, 1)
	assert.Equal(t, entries[0], "hello.com")
}

func TestSameIp(t *testing.T) {
	l := initDnsMatchCache(1)
	l.AddEntry("192.168.1.1", "hello.com")
	l.AddEntry("192.168.1.1", "world.com")
	assert.True(t, l.HasEntry("192.168.1.1", "hello.com"))
	assert.True(t, l.HasEntry("192.168.1.1", "world.com"))
}

func TestEviction(t *testing.T) {
	l := initDnsMatchCache(1)
	l.AddEntry("192.168.1.1", "hello.com")
	l.AddEntry("192.168.1.2", "world.com")
	assert.False(t, l.HasEntry("192.168.1.1", "hello.com"))
	assert.True(t, l.HasEntry("192.168.1.2", "world.com"))
}
