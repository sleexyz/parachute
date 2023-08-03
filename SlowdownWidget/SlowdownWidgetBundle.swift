//
//  SlowdownWidgetBundle.swift
//  SlowdownWidget
//
//  Created by Sean Lee on 8/2/23.
//

import WidgetKit
import SwiftUI

@main
struct SlowdownWidgetBundle: WidgetBundle {
    var body: some Widget {
        SlowdownWidget()
        SlowdownWidgetLiveActivity()
    }
}
