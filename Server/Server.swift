//
//  Server.swift
//  Server
//
//  Created by Sean Lee on 1/7/23.
//

import Foundation
import Ffi
import Logging
import ProxyService

#if DEBUG
            let env = "dev"
#else
            let env = "prod"
#endif

public struct Server {
    let bridge: FfiProxyBridgeProtocol
    let logger: Logger = Logger(label: "industries.strange.slowdown.Server")
    
    private init(bridge: FfiProxyBridgeProtocol) {
        self.bridge = bridge
    }
    
    public static func InitTunnelServer(settings: Proxyservice_Settings, device: Ffi.FfiDeviceCallbacksProtocol) -> Server {
        Ffi.FfiMaxProcs(1)
        Ffi.FfiSetMemoryLimit(20<<20)
        Ffi.FfiSetGCPercent(50)
        
        if settings.debug {
            return Server(bridge: Ffi.FfiInitDebug(env, "192.168.1.225:8080", "192.168.1.225:8083")!)
        }
        return Server(bridge: Ffi.FfiInit(env, device)!)
    }
    
    public func startProxy(port: Int, settingsData: Data) {
        bridge.startUDPServer(port, settingsData: settingsData)
    }
    
    public func startDirectProxyConnection(tunConn: Ffi.FfiCallbacksProtocol, settingsData: Data) {
        bridge.startDirectProxyConnection(tunConn, settingsData: settingsData)
    }
    
    public func writeOutboundPacket(_ data: Data) {
        bridge.writeOutboundPacket(data)
    }
    
    public func close() {
        bridge.close()
    }
    
    public func rpc(input: Data?) throws -> Data {
        return try bridge.rpc(input)
    }
}
