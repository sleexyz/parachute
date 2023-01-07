package main

import (
	"fmt"
	"os"

	"google.golang.org/protobuf/proto"
	"strange.industries/go-proxy/pb/proxyservice"
	"strange.industries/go-proxy/pkg/controller"
)

type DebugSettingsManager struct {
	*controller.SettingsManagerImpl
}

func InitDebugSettingsManager() *DebugSettingsManager {
	sm := &DebugSettingsManager{
		SettingsManagerImpl: controller.InitSettingsManager(),
	}
	var settings proxyservice.Settings
	readSettings(&settings)
	sm.SettingsManagerImpl.SetSettings(&settings)
	return sm
}

func (sm *DebugSettingsManager) SetSettings(settings *proxyservice.Settings) {
	sm.SettingsManagerImpl.SetSettings(settings)
	writeSettings(settings)
}

func getSettingsFileName() string {
	return fmt.Sprintf("%s/slowdown-debug-server-settings.json", os.Getenv("TMPDIR"))
}

func readSettings(settings *proxyservice.Settings) {
	bytes, err := os.ReadFile(getSettingsFileName())
	if err != nil && os.IsNotExist(err) {
		return
	} else if err != nil {
		panic(err)
	}
	err = proto.Unmarshal(bytes, settings)
	if err != nil {
		panic(err)
	}
}

func writeSettings(settings *proxyservice.Settings) {
	m, err := proto.Marshal(settings)
	if err != nil {
		panic("error marshalling settings in debug server")
	}
	os.WriteFile(getSettingsFileName(), m, 0644)
}
