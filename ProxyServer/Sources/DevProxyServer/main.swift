import ProxyServer
import Logging
import Darwin
import Dispatch


let logger = Logger(label: "com.strangeindustries.slowdown.DevProxyServer")
let options = ProxyServerOptions(ipv4Address: "0.0.0.0", ipv4Port: 8080, ipv6Address: "::", ipv6Port:8080)
let proxyServer = ProxyServer(logger:  logger, options: options)

proxyServer.start()
dispatchMain()
