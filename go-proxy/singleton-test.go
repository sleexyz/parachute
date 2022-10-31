package main

import (
	"log"
	"strconv"

	"os"

	"strange.industries/go-proxy/singleton"
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
	singleton.Start(port, "[::1]:8079")
	defer singleton.Close()
}
