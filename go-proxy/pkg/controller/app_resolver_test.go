package controller

import (
	"regexp"
	"testing"

	"github.com/stretchr/testify/assert"
)

func makeTestAppResolver() *AppResolver {
	ar := InitAppResolver(&AppResolverOptions{
		failedIpMatchCacheSize:  1,
		failedDnsMatchCacheSize: 1,
		apps: []*App{
			InitApp("social", &AppMatcher{
				dnsMatchers: []*regexp.Regexp{
					regexp.MustCompile(`hello\.com\.$`),
				},
			}),
		},
	})
	return ar
}

func TestRegisterDnsEntryIdentity(t *testing.T) {
	ar := makeTestAppResolver()
	ar.RegisterDnsEntry("1.2.3.4", "hello.com.")
	assert.Equal(t, ar.appMap["1.2.3.4"].Name(), "social")
}

func TestRegisterDnsEntryNonMatch(t *testing.T) {
	ar := makeTestAppResolver()
	ar.RegisterDnsEntry("1.2.3.4", "non-match.com.")
	assert.True(t, ar.failedDnsMatchCache.Has("1.2.3.4"))
	ar.RegisterDnsEntry("5.6.7.8", "another-non-match.com.")
	assert.False(t, ar.failedDnsMatchCache.Has("1.2.3.4"), "expected eviction")
	assert.True(t, ar.failedDnsMatchCache.Has("5.6.7.8"), "expected eviction")
}
