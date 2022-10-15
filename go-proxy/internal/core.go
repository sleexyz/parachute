package internal

// Defines a leg of a duplex connection
type Conn interface {
	Write(b []byte) (int, error)
	Read(b []byte) (int, error)
	Close()
}

type Sink interface {
	Write(b []byte) (int, error)
}
