//
//  Proxy.swift
//  tunnel
//
//  Created by Sean Lee on 12/13/22.
//

import Foundation
import Ffi
import Logging


public struct Proxy {
    let bridge: FfiProxyBridgeProtocol
    let logger: Logger
    
    let encoder = JSONEncoder()
    
    func startProxy(port: Int, settingsData: Data) {
        bridge.startProxy(port, settingsData: settingsData)
    }
    
    func close() {
        bridge.close()
    }
    
    func rpc(input: Data?) throws {
        try bridge.rpc(input)
    }
}
