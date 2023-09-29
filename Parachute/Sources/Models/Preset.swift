//
//  Preset.swift
//  slowdown
//
//  Created by Sean Lee on 2/27/23.
//

import Foundation
import ProxyService
import SwiftUI

// Information is totally lost here other than presetData.
public struct Preset {
    public var presetData: Proxyservice_Preset
    public var overlayDurationSecs: Double?

    public init(presetData: Proxyservice_Preset, overlayDurationSecs: Double? = nil) {
        self.presetData = presetData
        self.overlayDurationSecs = overlayDurationSecs
    }

    public static var quickBreak: Preset {
        Preset(
            presetData: .relax,
            overlayDurationSecs: 30
        )
    }

    public static var scrollSession: Preset {
        Preset(
            presetData: .relax,
            overlayDurationSecs: 5 * 60
        )
    }

    public static var focus: Preset {
        Preset(
            presetData: .focus
        )
    }
}

public extension Proxyservice_Preset {
    static var focus: Proxyservice_Preset {
        Proxyservice_Preset.with {
            $0.baseRxSpeedTarget = 40e3
        }
    }

    static var relax: Proxyservice_Preset {
        Proxyservice_Preset.with {
            $0.baseRxSpeedTarget = .infinity
        }
    }
}
