package ffi

import (
	"log"
	"runtime"
	"runtime/debug"

	"strange.industries/go-proxy/pkg/analytics"
	"strange.industries/go-proxy/pkg/controller"
	proxy "strange.industries/go-proxy/pkg/proxy"
)

type DeviceCallbacks interface {
	SendNotification(title string, message string)
}

func InitDebug(env string, dataAddr string, controlAddr string) ProxyBridge {
	log.SetOutput(MobileLogger{})
	return InitDebugClientProxyBridge(dataAddr, controlAddr)
}

func Init(env string, dc DeviceCallbacks) ProxyBridge {
	// log.SetOutput(io.Discard)
	log.SetOutput(MobileLogger{})
	a := &analytics.NoOpAnalytics{}
	sm := controller.InitSettingsManager()
	c := controller.Init(a, sm, controller.ProdAppConfigs, dc)
	return &OnDeviceProxyBridge{
		OutboundChannel: InitOutboundChannel(),
		Proxy:           proxy.InitOnDeviceProxy(a, c),
	}
}

func MaxProcs(max int) int {
	return runtime.GOMAXPROCS(max)
}

func SetMemoryLimit(limit int64) int64 {
	return debug.SetMemoryLimit(limit)
}

func SetGCPercent(pct int) int {
	return debug.SetGCPercent(pct)
}
