package controller

import (
	"log"

	"strange.industries/go-proxy/pb/proxyservice"
)

type SettingsChangeListener interface {
	BeforeSettingsChange()
	OnSettingsChange(oldSettings *proxyservice.Settings, newSettings *proxyservice.Settings)
}

type SettingsProvider interface {
	Settings() *proxyservice.Settings
	RegisterChangeListener(listener SettingsChangeListener)
}

type SettingsManager interface {
	SettingsProvider
	SetSettings(settings *proxyservice.Settings)
}

type SettingsManagerImpl struct {
	changeListeners []SettingsChangeListener
	settings        *proxyservice.Settings
}

func InitSettingsManager() *SettingsManagerImpl {
	return &SettingsManagerImpl{
		settings:        &proxyservice.Settings{},
		changeListeners: []SettingsChangeListener{},
	}
}

func (sm *SettingsManagerImpl) RegisterChangeListener(listener SettingsChangeListener) {
	sm.changeListeners = append(sm.changeListeners, listener)
}

func (sm *SettingsManagerImpl) Settings() *proxyservice.Settings {
	return sm.settings
}

func (sm *SettingsManagerImpl) SetSettings(settings *proxyservice.Settings) {
	for _, listener := range sm.changeListeners {
		listener.BeforeSettingsChange()
	}

	log.Printf("settings: %v", settings)
	oldSettings := sm.settings
	sm.settings = settings

	for _, listener := range sm.changeListeners {
		listener.OnSettingsChange(oldSettings, sm.settings)
	}
}
