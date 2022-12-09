# go-proxy

Packet forwarding router proxy server, implemented in Go.

Development
```
git ls-files| entr -cr go run local-proxy/.
```

With wireshark
```
# 1 -- starts the traffic tee, which proxies traffic to 8081 and tees all packets to 8082
PORT=8080 go run ./tee/server/.

# 2 -- starts the proxy on 8081
git ls-files | entr -crs 'PORT=8081 go run ./local-proxy/main.go'

# 3 -- connects traffic tee on 8082
go run ./tee/client/.
```

Building for ios
```
./build.sh
```

## Design

Problem: iOS gives us given raw packets (Layer 3, IP-level packets), and we need to forward them on device without raw socket access.

To solve this, we use a userspace network stack provided by gvisor to recreate the tcp connections and forward the packets along.

### Technical details:

Through PacketTunnelProvider, iOS creates a TUN device (henceforth called "`TUN`") that all device traffic gets written to. Our job is to read packets from `TUN`, send them out, and write packets back.

With a userspace network stack, we can create a virtual device (henceforth called "`userTUN`") and bridge the connection by 1) writing raw packets to `userTUN` and 2) recreating the tcp connections.

`router` 1) manages `userTUN` and 2) glues `TUN` to `userTUN`
  - This gluing is simply a port-NAT between `TUN` and `userTUN`.
  - No address-NAT is needed -- we use the same proxy address between the two devices (`10.0.0.8`).


`userTUN` has listeners that:
 1. (egress) listen for outbound packets from `10.0.0.8` and forward them along.
 1. (ingress) listen for inbound packets from `10.0.0.8` and writes them back to `TUN` via `tunconn`

`tunconn` is a layer that connects `router` to `TUN`.

### Flow summary

Egress:

- App sends a packet.
- iOS routes it to `TUN`
- (`TUN` to `userTUN`)
    - PacketTunnelProvider reads packet from `TUN`
    - PacketTunnelProvider writes it to `router` via `tunconn`
    - `router` reads packet from `tunconn`
    - `router` writes the packet to `userTUN`
- `userTUN` egress handlers write the packet out to the internet via TCP/UDP connections.

Ingress:

- TCP/UDP connection write packets back to `userTUN`.
- (`userTUN` to `TUN`):
    - `userTUN` ingress handlers recieve packet.
    - `router` write packet to `tunconn`.
    - PacketTunnelProvider receives packet from `tunconn`.
    - PacketTunnel writes it to `TUN`.
- iOS routes it to the app.
- App receives a packet.
