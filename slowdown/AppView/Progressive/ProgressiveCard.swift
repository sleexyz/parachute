//
//  ProgressiveModeView.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import SwiftUI
import ProxyService
import Combine

struct ProgressiveCard<Content: View>: View {
    var preset: Preset
    
    @ViewBuilder
    var content: () -> Content
    
    
    var scrollTimeText: String {
        return "Limits scrolling to \(Int(preset.scrollTimeLimit)) minute\(Int(preset.scrollTimeLimit) != 1 ? "s" : "")"
    }
    
    var body: some View {
        Card(
            title: preset.name,
            caption: scrollTimeText,
            backgroundColor: preset.mainColor,
            material: .thinMaterial.opacity(preset.opacity)
        ) {
            content()
        }
    }
}

//struct ProgressiveModeView_Expanded: PreviewProvider {
//    static var previews: some View {
//        VStack(spacing: 20) {
//            ForEach([1, 5], id: \.self) { i in
//                EnvironmentObjectProxy(type: SettingsStore.self) { store in
//                    ProgressiveCard(model: PresetViewModel(presetData: store.activePresetBinding, preset: PresetManager.getPreset(id: store.activePreset.id))) {
//                        EmptyView()
//                    }
//                }
//                .consumeDep(StateController.self) { value in
//                    value.setState(value: Proxyservice_GetStateResponse.with {
//                        $0.usagePoints = Double(i)
//                    })
//                }
//                .provideDeps(connectedPreviewDeps)
//            }
//        }
//    }
//}
