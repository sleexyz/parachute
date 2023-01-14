package main

import "log"

type MockDeviceCallbacks struct {
}

func (*MockDeviceCallbacks) SendNotification(title string, msg string) {
	log.Printf("Would send notification title: %s, message: %s", title, msg)
}
