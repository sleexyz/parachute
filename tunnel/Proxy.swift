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
    
    func start(port: Int) throws {
      try bridge.command("Start", input: encoder.encode(port))
    }
    
    func close() throws {
        try bridge.command("Close",input: nil)
    }
    
    func setBaseRxSpeedTarget(target: Float64) throws {
        try bridge.command("SetBaseRxSpeedTarget",input: encoder.encode(target))
    }
    
    func pause() throws {
        try bridge.command("SetTemporaryRxSpeedTarget",input: encoder.encode(SetTemporaryRxSpeedTargetRequest(target:-1, duration:60)))
    }
}
