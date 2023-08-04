//
//  ServerTests.swift
//  ServerTests
//
//  Created by Sean Lee on 1/7/23.
//

import XCTest
import Ffi
@testable import Server

import ProxyService

class MockDeviceCallbacks: NSObject, FfiDeviceCallbacksProtocol {
    func sendNotification(_ title: String?, message: String?) {
    }
}

class MockTunConn: NSObject, FfiCallbacksProtocol {
    func writeInboundPacket(_ b: Data?) {
    }
}

final class ServerTests: XCTestCase {
    var server: Server?

    override func setUpWithError() throws {
        let settings = Proxyservice_Settings()
        server = Server.InitTunnelServer(settings: settings, deviceCallbacks: MockDeviceCallbacks())
        server!.startDirectProxyConnection(tunConn: MockTunConn(), settingsData: try settings.serializedData())
    }

    override func tearDownWithError() throws {
        server!.close()
    }

    func testGetStateResponse() throws {
        var request = Proxyservice_Request()
        request.getState = Proxyservice_GetStateRequest()
        _ = server!.rpc(input: try request.serializedData())
    }
    
    func testSetSettingsResponse() throws {
        var request = Proxyservice_Request()
        request.setSettings = Proxyservice_Settings()
        _ = server!.rpc(input: try request.serializedData())
    }
}
