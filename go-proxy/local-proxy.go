// Local proxy
package main

import (
	"log"
	"runtime"
	"strconv"

	"os"

	_ "net/http/pprof"

	"github.com/pyroscope-io/client/pyroscope"
	"strange.industries/go-proxy/singleton"
)

func main() {
	portStr := os.Getenv("PORT")
	if portStr == "" {
		portStr = "8080"
	}
	port, err := strconv.Atoi(portStr)
	if err != nil {
		log.Panicln("could not parse $PORT")
	}

	runtime.SetMutexProfileFraction(5)
	runtime.SetBlockProfileRate(5)

	pyroscope.Start(pyroscope.Config{
		ApplicationName: "strangeindustries.goproxy",

		// replace this with the address of pyroscope server
		ServerAddress: "http://localhost:4040",

		// you can disable logging by setting this to nil
		// Logger: pyroscope.StandardLogger,
		Logger: nil,

		// optionally, if authentication is enabled, specify the API key:
		// AuthToken: os.Getenv("PYROSCOPE_AUTH_TOKEN"),

		ProfileTypes: []pyroscope.ProfileType{
			// these profile types are enabled by default:
			pyroscope.ProfileCPU,
			pyroscope.ProfileAllocObjects,
			pyroscope.ProfileAllocSpace,
			pyroscope.ProfileInuseObjects,
			pyroscope.ProfileInuseSpace,

			// these profile types are optional:
			pyroscope.ProfileGoroutines,
			pyroscope.ProfileMutexCount,
			pyroscope.ProfileMutexDuration,
			pyroscope.ProfileBlockCount,
			pyroscope.ProfileBlockDuration,
		},
	})

	singleton.MaxProcs(1)
	singleton.SetMemoryLimit(10 << 20)
	// singleton.SetGCPercent(20)
	defer singleton.Close()
	singleton.Start(port)
	// ctx := context.Background()
	// <-ctx.Done()
}
