//
//  AppModeCarousel.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import SwiftUI
import ProxyService

struct AppModeCarousel: View {
    @ObservedObject var model: AppViewModel
    @EnvironmentObject var cheatController: CheatController
    @EnvironmentObject var controller: SettingsController
    var modes: [Mode] {
        return [
            Mode(
                id:"progressive",
                onEnter: {
                    controller.switchMode(mode: Proxyservice_Mode.progressive)
                }
            ),
            Mode(
                id:"focus",
                onEnter: {
                    controller.switchMode(mode: Proxyservice_Mode.focus)
                }
            ),
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
            index: $model.currentCarouselIndex, items: modes
        ) {mode in
            
            switch mode.id {
            case "progressive":
//                ProgressiveCard(active: true)
                FocusModeView()
            case "focus":
                FocusModeView()
            case "break":
                BreakModeView()
            default:
                EmptyView()
            }
        }.onChange(of: cheatController.isCheating) {value in
            model.currentCarouselIndex = value ? 2 : 1
        }
    }
    
}
