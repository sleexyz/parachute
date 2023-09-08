//
//  ServerTests.swift
//  ServerTests
//
//  Created by Sean Lee on 1/7/23.
//

import Ffi
@testable import Server
import XCTest

import ProxyService

class MockDeviceCallbacks: NSObject, FfiDeviceCallbacksProtocol {
    func sendNotification(_: String?, message _: String?) {}
}

class MockTunConn: NSObject, FfiCallbacksProtocol {
    func writeInboundPacket(_: Data?) {}
}

final class ServerTests: XCTestCase {
    var server: Server?

    override func setUpWithError() throws {
        let settings = Proxyservice_Settings()
        server = Server.InitTunnelServer(settings: settings, deviceCallbacks: MockDeviceCallbacks())
        try server!.startDirectProxyConnection(tunConn: MockTunConn(), settingsData: settings.serializedData())
    }

    override func tearDownWithError() throws {
        server!.close()
    }

    func testGetStateResponse() throws {
        var request = Proxyservice_Request()
        request.getState = Proxyservice_GetStateRequest()
        _ = try server!.rpc(input: request.serializedData())
    }

    func testSetSettingsResponse() throws {
        var request = Proxyservice_Request()
        request.setSettings = Proxyservice_Settings()
        _ = try server!.rpc(input: request.serializedData())
    }
}
