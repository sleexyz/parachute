//
//  ProgressiveModeView.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import SwiftUI




struct ProgressiveModeView: View {
    @ObservedObject var store: SettingsStore = .shared
    @ObservedObject var stateController: StateController = .shared
    var controller: SettingsController = .shared
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    
    var body: some View {
        VStack {
            HStack {
                DamageBar(damage: stateController.state.usagePoints, maxHP: store.settings.usageMaxHp)
            }
            HStack {
                Text("Max HP")
                TextField("Max HP (min)", value: $store.settings.usageMaxHp, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onSubmit {
                        controller.syncSettings()
                    }
            }
            HStack {
                Text("Heal rate")
                TextField("Heal rate (HP / min)", value: $store.settings.usageHealRate, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onSubmit {
                        controller.syncSettings()
                    }
            }
            Spacer()
            Button(action: stateController.heal) {
                Text("🤤")
            }
            .font(.system(size: 72))
            .padding()
            .frame(maxWidth: .infinity)
            Spacer()
        }.onReceive(timer) {_ in
            self.stateController.fetchState()
        }
    }
}

struct ProgressiveModeView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressiveModeView()
    }
}
