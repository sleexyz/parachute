//
//  Settings Extensions.swift
//  Common
//
//  Created by Sean Lee on 2/15/23.
//

import Foundation
import ProxyService

extension Proxyservice_Settings {
    public func isPaused() -> Bool {
        return self.hasPauseExpiry && self.pauseExpiry.date.timeIntervalSinceNow > 0
    }
}
