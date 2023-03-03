//
//  FocusModeView.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import SwiftUI
    
struct FocusModeView : View {
    @EnvironmentObject var model: AppViewModel
    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var controller: SettingsController
    var body: some View {
        VStack {
            Slider(
                value: model.logSpeed,
                in: (11...16),
                onEditingChanged: { editing in
                    if !editing {
                        controller.syncSettings()
                    }
                }
            ).padding()
            Text("\(Int(store.activePreset.baseRxSpeedTarget))")
            Text("😎")
                .font(.system(size: 144))
                .padding()
                .frame(maxWidth: .infinity)
        }
    }
}

struct Previews_FocusModeView_Previews: PreviewProvider {
    static var previews: some View {
        FocusModeView()
            .provideDeps(previewDeps)
    }
}
