package logger

import "log"

var Logger = log.Default()

func SetGlobalLogger(logger *log.Logger) {
	Logger = logger
}
