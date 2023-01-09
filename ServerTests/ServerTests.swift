//
//  ServerTests.swift
//  ServerTests
//
//  Created by Sean Lee on 1/7/23.
//

import XCTest
@testable import Server

import ProxyService

final class ServerTests: XCTestCase {
    var server: Server?

    override func setUpWithError() throws {
        let settings = Proxyservice_Settings()
        server = Server.InitTunnelServer(settings: settings)
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
