package controller

import "strange.industries/go-proxy/pb/proxyservice"

type SettingsChangeListener interface {
	BeforeSettingsChange()
	OnSettingsChange(oldSettings *proxyservice.Settings, newSettings *proxyservice.Settings)
}

type SettingsProvider interface {
	Settings() *proxyservice.Settings
	RegisterChangeListener(listener SettingsChangeListener)
}

type SettingsManager struct {
	changeListeners []SettingsChangeListener
	settings        *proxyservice.Settings
}

func InitSettingsManager() *SettingsManager {
	return &SettingsManager{
		settings:        &proxyservice.Settings{},
		changeListeners: []SettingsChangeListener{},
	}
}

func (sm *SettingsManager) RegisterChangeListener(listener SettingsChangeListener) {
	sm.changeListeners = append(sm.changeListeners, listener)
}

func (sm *SettingsManager) Settings() *proxyservice.Settings {
	return sm.settings
}

func (sm *SettingsManager) SetSettings(settings *proxyservice.Settings) {
	for _, listener := range sm.changeListeners {
		listener.BeforeSettingsChange()
	}

	oldSettings := sm.settings
	sm.settings = settings

	for _, listener := range sm.changeListeners {
		listener.OnSettingsChange(oldSettings, sm.settings)
	}
}
