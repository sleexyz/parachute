//
//  ProgressiveModeView.swift
//  slowdown
//
//  Created by Sean Lee on 1/5/23.
//

import Foundation
import SwiftUI
import ProxyService

struct ProgressiveModeView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var stateController: StateController
    @EnvironmentObject var controller: SettingsController
    
    @State var expanded: Bool = false
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

//    var theme: Theme = Theme.navy
    var level: Double {
        if levelOverride != nil {
            return levelOverride!
        }
        return store.scrollTimeLimit.wrappedValue
            .linmap(10, 0, 0, 3, clip: true)
    }
    var levelOverride: Double?
    var mainColor: Color {
        let h: Double = 259/360
        let s = level.linmap(0, 3, 0.2, 1, warp: .linear)
        let b = level.linmap(0, 3, 0.67, 0.4, warp: .linear)
        return Color(hue: h, saturation: s, brightness: b)
    }
    
    var accentColor: Color = Color.white
//    var theme: Theme = Theme.poppy
    
    var tap: some Gesture {
        TapGesture(count: 1)
            .onEnded {
            if !self.expanded {
                self.expanded = true
            }
        }
    }
    
    var shape: some Shape {
        RoundedRectangle(cornerRadius: 50, style: .continuous)
    }
    
    var body: some View {
        let scrollTimeLimit = Int(store.scrollTimeLimit.wrappedValue)
        let ratio = 1 - stateController.state.usagePoints / store.settings.usageMaxHp
        VStack {
            Text("Scroll Limit: \(scrollTimeLimit) minute\(scrollTimeLimit > 1 ? "s" : "")")
                .font(.headline)
                .padding()
            Spacer()
            StagedDamageBar(
                ratio: ratio,
                height: 30
            )
            .padding()
            Spacer()
            if expanded {
                HealSettings()
                    .padding()
                Spacer()
            }
            HealButton()
                .padding()
                .frame(maxWidth: .infinity)
        }
        .contentShape(shape)
        .gesture(tap)
        .foregroundColor(accentColor)
        .background(mainColor)
        .clipShape(shape)
        .frame(height: expanded ? 400 : 200)
        .animation(.default, value: expanded)
        .onTapBackground(enabled: self.expanded) {
            self.expanded = false
        }
        .onReceive(timer) {_ in
            self.stateController.fetchState()
        }
    }
}

struct HealSettings: View {
    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var controller: SettingsController
    
    @FocusState private var scrollTimeFocused: Bool
    @FocusState private var restTimeFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Scroll time")
                TextField("Scroll time (min)", value: store.scrollTimeLimit, format: .number)
                    .focused($scrollTimeFocused)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(nil)
                    .padding()
                    .removeFocusOnTap(enabled: scrollTimeFocused)
                    .onSubmit {
                        controller.syncSettings()
                    }
            }
            HStack {
                Text("Rest time")
                TextField("Rest time", value: store.restTime, format: .number)
                    .focused($restTimeFocused)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(nil)
                    .padding()
                    .removeFocusOnTap(enabled: restTimeFocused)
                    .onSubmit {
                        controller.syncSettings()
                    }
            }
        }
    }
}

struct HealButton: View {
    @EnvironmentObject var stateController: StateController

    var body: some View {
        let opacity = stateController.isSlowing ? 1 : 0.5
        Text("One more minute!")
            .font(.system(.body))
            .padding()
            .foregroundColor(Color.white)
            .background(Color.accentColor.grayscale(1))
            .clipShape(RoundedRectangle(cornerRadius: 100, style:.continuous))
            .opacity(opacity)
            .disabled(!stateController.isSlowing)
            .onTapGesture {
                stateController.heal()
            }
        
    }
}

struct ProgressiveModeView_Previews: PreviewProvider {

    static var previews: some View {
        VStack(spacing: 20) {
            ForEach([2, 3, 4, 5], id: \.self) { i in
                ProgressiveModeView()
                    .consumeDep(StateController.self) { value in
                        value.setState(value: Proxyservice_GetStateResponse.with {
                            $0.usagePoints = Double(i)
                        })
                    }
                    .provideDeps(previewDeps)
            }
        }
    }
}
