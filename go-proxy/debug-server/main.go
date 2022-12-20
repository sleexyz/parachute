package main

import (
	"log"
	"runtime"
	"runtime/debug"
	"strconv"

	"os"

	_ "net/http/pprof"

	// "github.com/pyroscope-io/client/pyroscope"

	ffi "strange.industries/go-proxy/pkg/ffi"
	"strange.industries/go-proxy/pkg/proxy"
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

	// pyroscope.Start(pyroscope.Config{
	// 	ApplicationName: "strangeindustries.goproxy",

	// 	// replace this with the address of pyroscope server
	// 	ServerAddress: "http://localhost:4040",

	// 	// you can disable logging by setting this to nil
	// 	// Logger: pyroscope.StandardLogger,
	// 	Logger: nil,

	// 	// optionally, if authentication is enabled, specify the API key:
	// 	// AuthToken: os.Getenv("PYROSCOPE_AUTH_TOKEN"),

	// 	ProfileTypes: []pyroscope.ProfileType{
	// 		// these profile types are enabled by default:
	// 		pyroscope.ProfileCPU,
	// 		pyroscope.ProfileAllocObjects,
	// 		pyroscope.ProfileAllocSpace,
	// 		pyroscope.ProfileInuseObjects,
	// 		pyroscope.ProfileInuseSpace,

	// 		// these profile types are optional:
	// 		pyroscope.ProfileGoroutines,
	// 		pyroscope.ProfileMutexCount,
	// 		pyroscope.ProfileMutexDuration,
	// 		pyroscope.ProfileBlockCount,
	// 		pyroscope.ProfileBlockDuration,
	// 	},
	// })
	runtime.GOMAXPROCS(1)
	debug.SetMemoryLimit(20 << 20)
	debug.SetGCPercent(50)

	a := InitAnalyticsServer(8084)
	proxy := proxy.InitOnDeviceProxy(a)
	a.Start()
	proxyBridge := &ffi.OnDeviceProxyBridge{Proxy: proxy}
	dsp := InitDebugServerProxy(proxyBridge, proxy)
	defer dsp.Close()
	dsp.Start(port)
	// ctx := context.Background()
	// <-ctx.Done()
}
