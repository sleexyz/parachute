//
//  SlowdownWidgetBundle.swift
//  SlowdownWidget
//
//  Created by Sean Lee on 8/2/23.
//

import SwiftUI
import WidgetKit

@main
struct SlowdownWidgetBundle: WidgetBundle {
    var body: some Widget {
        SlowdownWidget()
        SlowdownWidgetLiveActivity()
    }
}
