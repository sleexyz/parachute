// Abstraction for connection layer to TUN

package tunconn

// Defines a leg of a duplex connection
type TunConn interface {
	Write(b []byte) (int, error)
	Read(b []byte) (int, error)
	Close()
}
