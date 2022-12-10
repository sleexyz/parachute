package controller

const (
	defaultTxLatency = 20
	defaultRxLatency = 20
)

type Controller struct {
	TxLatency int
	RxLatency int
}

func Init() *Controller {
	return &Controller{
		TxLatency: defaultTxLatency,
		RxLatency: defaultRxLatency,
	}
}

func (c *Controller) SetLatency(latency int) {
	c.TxLatency = 0
	c.RxLatency = 0
}
