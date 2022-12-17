//
//  Proxy.swift
//  tunnel
//
//  Created by Sean Lee on 12/13/22.
//

import Foundation
import Ffi
import Logging

public struct SetTemporaryRxSpeedTargetRequest: Encodable {
    public var target: Float64
    public var duration: Int
}

public struct Proxy {
    let bridge: FfiProxyBridgeProtocol
    let logger: Logger
    
    let encoder = JSONEncoder()
    
    func start(port: Int) {
        bridge.start(port)
    }
    
    func close() {
        bridge.close()
    }
    
    func rpc(input: Data?) throws {
        try bridge.rpc(input)
    }
}
