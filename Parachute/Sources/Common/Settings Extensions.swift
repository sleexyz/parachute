//
//  Settings Extensions.swift
//  Common
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import ProxyService

public extension String {
    static var vendorConfigurationKey = "slowdown-settings"
}

extension Proxyservice_Preset: Identifiable {
    public typealias ID = String
}
