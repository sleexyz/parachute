package internal

type IConn interface {
	Write(b []byte) (int, error)
	Read(b []byte) (int, error)
	Close()
}
