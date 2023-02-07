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

final class ServerTests: XCTestCase {
    var server: Server?

    override func setUpWithError() throws {
        let settings = Proxyservice_Settings()
        server = Server.InitTunnelServer(settings: settings, deviceCallbacks: MockDeviceCallbacks())
        server!.startProxy(port: 8080, settingsData: try settings.serializedData())
    }

    override func tearDownWithError() throws {
        server!.close()
    }

    func testGetStateResponseIsNotNil() throws {
        var request = Proxyservice_Request()
        request.getState = Proxyservice_GetStateRequest()
        let resp = try Proxyservice_Response(serializedData: try server!.rpc(input: try request.serializedData()))
        XCTAssertNotNil(resp.getState)
    }
    
    func testSetSettingsResponseIsNotNil() throws {
        var request = Proxyservice_Request()
        request.setSettings = Proxyservice_Settings()
        let resp = try Proxyservice_Response(serializedData: try server!.rpc(input: try request.serializedData()))
        XCTAssertNotNil(resp.setSettings)
    }
}
