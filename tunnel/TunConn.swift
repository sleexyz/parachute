//
//  TunConn.swift
//  tunnel
//
//  Data plane callback interface.
//
//  Created by Sean Lee on 2/6/23.
//

import Foundation
import NetworkExtension
import Ffi

class TunConn: NSObject, FfiCallbacksProtocol {
    var packetFlow: NEPacketTunnelFlow {
        return packetFlowGetter()
    }
    
    var packetFlowGetter: () -> NEPacketTunnelFlow
    
    init(packetFlowGetter: @escaping () -> NEPacketTunnelFlow) {
        self.packetFlowGetter = packetFlowGetter
    }
    
    func writeInboundPacket(_ data: Data?) {
        guard let data = data else {
            fatalError("data is nil")
        }
        self.packetFlow.writePackets([data], withProtocols: [PacketTunnelProvider.protocolNumber(for: data)])
    }
}

