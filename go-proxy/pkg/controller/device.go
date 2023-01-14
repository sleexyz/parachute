package controller

type DeviceCallbacks interface {
	SendNotification(title string, message string)
}
