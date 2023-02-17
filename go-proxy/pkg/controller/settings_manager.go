package controller

import (
	"log"

	"strange.industries/go-proxy/pb/proxyservice"
)

type SettingsChangeListener interface {
	BeforeSettingsChange()
	OnSettingsChange(oldPreset *proxyservice.Preset, newPreset *proxyservice.Preset)
}

type SettingsProvider interface {
	Settings() *proxyservice.Settings
	ActivePreset() *proxyservice.Preset
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
		settings: &proxyservice.Settings{
			ActivePreset: &proxyservice.Preset{},
		},
		changeListeners: []SettingsChangeListener{},
	}
}

func (sm *SettingsManagerImpl) RegisterChangeListener(listener SettingsChangeListener) {
	sm.changeListeners = append(sm.changeListeners, listener)
}

func (sm *SettingsManagerImpl) Settings() *proxyservice.Settings {
	return sm.settings
}

func (sm *SettingsManagerImpl) ActivePreset() *proxyservice.Preset {
	return sm.settings.ActivePreset
}

func (sm *SettingsManagerImpl) SetSettings(settings *proxyservice.Settings) {
	for _, listener := range sm.changeListeners {
		listener.BeforeSettingsChange()
	}

	// normalize settings
	if settings.ActivePreset == nil {
		settings.ActivePreset = &proxyservice.Preset{}
	}

	log.Printf("settings: %v", settings)
	oldPreset := sm.ActivePreset()
	sm.settings = settings

	for _, listener := range sm.changeListeners {
		listener.OnSettingsChange(oldPreset, sm.ActivePreset())
	}
}
