package controller

import (
	"log"
	"time"

	"strange.industries/go-proxy/pb/proxyservice"
)

type SettingsChangeListener interface {
	BeforeSettingsChange()
	OnPresetChange(oldPreset *proxyservice.Preset, newPreset *proxyservice.Preset)
	OnSettingsChange(oldSettings *proxyservice.Settings, newSettings *proxyservice.Settings)
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
			DefaultPreset: &proxyservice.Preset{},
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

// TODO: cache value
func (sm *SettingsManagerImpl) ActivePreset() *proxyservice.Preset {
	if overlay := sm.settings.Overlay; overlay != nil {
		if overlay.Expiry.AsTime().After(time.Now()) {
			return overlay.Preset
		}
	}
	return sm.settings.DefaultPreset
}

func (sm *SettingsManagerImpl) SetSettings(settings *proxyservice.Settings) {
	for _, listener := range sm.changeListeners {
		listener.BeforeSettingsChange()
	}

	// normalize settings
	if settings.DefaultPreset == nil {
		settings.DefaultPreset = &proxyservice.Preset{}
	}

	oldSettings := sm.settings

	log.Printf("settings: %v", settings)
	oldPreset := sm.ActivePreset()
	sm.settings = settings

	for _, listener := range sm.changeListeners {
		listener.OnPresetChange(oldPreset, sm.ActivePreset())
		listener.OnSettingsChange(oldSettings, settings)
	}
}
