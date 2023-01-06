//
//  AppModeCarousel.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import SwiftUI

struct AppModeCarousel: View {
    @ObservedObject var model: AppViewModel
    @ObservedObject var cheatController: CheatController = .shared
    var modes: [Mode]
    
    init(model: AppViewModel, cheatController: CheatController = .shared) {
        self.model = model
        self.cheatController = cheatController
        self.modes = [
            Mode(id:"progressive"),
            Mode(id:"focus"),
            Mode(
                id:"break",
                onEnter: {
                    if !cheatController.isCheating {
                        model.startCheat()
                    }
                },
                onExit: {
                    if cheatController.isCheating {
                        model.stopCheat()
                    }
                }
            ),
        ]
    }
    var body: some View {
        SnapCarousel(
            spacing:  0,
            trailingSpace: 0,
            index: $model.currentIndex, items: modes
        ) {mode in
            
            switch mode.id {
            case "progressive":
                ProgressiveModeView()
            case "focus":
                FocusModeView()
            case "break":
                BreakModeView()
            default:
                EmptyView()
            }
        }.onChange(of: cheatController.isCheating) {value in
            model.currentIndex = value ? 2 : 1
        }
    }
    
}
