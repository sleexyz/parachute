//
//  Profile.swift
//  slowdown
//
//  Created by Sean Lee on 3/10/23.
//

import Foundation
import OrderedCollections
import ProxyService
import SwiftUI

typealias PresetID = String

struct Profile {
    // id should match defaultpreset id
    var id: String
    var childPresets: OrderedSet<PresetID> = []
    var presets: OrderedSet<PresetID> {
        var ret = OrderedSet<PresetID>()
        ret.append(id)
        ret.append(contentsOf: childPresets)
        return ret
    }
}

extension Profile: Identifiable {
}
