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
    
    func start(port: Int) {
        do {
            try bridge.command("Start", input: encoder.encode(port))
        } catch {
            logger.error("Error: \(error)")
        }
    }
    
    func close() {
        bridge.command("Close",input: nil)
    }
    
    func pause() {
        bridge.command("Pause",input: nil)
    }
}
