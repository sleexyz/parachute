package proxy

const (
	proxyAddr = "10.0.0.8"
)

type Proxy interface {
	Start(port int)
	Close()
}
