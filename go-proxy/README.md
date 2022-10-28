# go-proxy

Test proxy implemented in Go

```
git ls-files| entr -cr go run .
```

## Design

Problem: iOS gives us given raw packets (Layer 3, IP-level packets), and we need to forward them on device without raw socket access.

To solve this, we use a userspace network stack provided by gvisor to recreate the tcp connections and forward the packets along.

To rephrase in lower level terms:

Through PacketTunnelProvider, iOS creates a TUN device (henceforth called "`TUN`") that all device traffic gets written to. Our job is to read packets from `TUN`, send them out, and write packets back.

### Technical details:

With a userspace network stack, we can create a virtual device (henceforth called "`userTUN`"). 

`server` is a server that glues `TUN` to `userTUN`.
  - Performs port NAT from `TUN` to `userTUN`.
  - No address-NAT is needed -- we use the same proxy address between the two devices (`10.0.0.8`).


`userTUN` has listeners that:

 1. (egress) listen for outbound packets from `10.0.0.8` and forward them along.
 1. (ingress) listen for inbound packets from `10.0.0.8` and writes them back to `TUN` via `tunconn`

`tunconn` is a layer that connects `server` to `TUN`.

### Flow summary

Egress:

- App sends a packet.
- iOS routes it to `TUN`
- (`TUN` to `userTUN`)
    - PacketTunnelProvider reads packet from `TUN`
    - PacketTunnelProvider writes it to `server` via `tunconn`
    - `server` reads packet from `tunconn`
    - `server` writes the packet to `userTUN`
- `userTUN` egress handlers write the packet out to the internet via TCP/UDP connections.

Ingress:

- TCP/UDP connection write packets back to `userTUN`.
- (`userTUN` to `TUN`):
    - `userTUN` ingress handlers recieve packet.
    - `server` write packet to `tunconn`.
    - PacketTunnelProvider receives packet from `tunconn`.
    - PacketTunnel writes it to `TUN`.
- iOS routes it to the app.
- App receives a packet.