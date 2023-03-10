//
//  Preset.swift
//  slowdown
//
//  Created by Sean Lee on 2/27/23.
//

import Foundation
import ProxyService
import SwiftUI

struct Preset {
    var name: String
    var presetData: Proxyservice_Preset
    var mainColor: Color?
    
    var overlayTimeSecs: Double {
        if presetData.mode == .progressive {
            return presetData.usageMaxHp * 60
        }
        return 10 * 60
    }
}
