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

struct ProgressiveModeView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var stateController: StateController
    @EnvironmentObject var controller: SettingsController
    
    @State var expanded: Bool = false

//    var theme: Theme = Theme.navy
    var level: Double {
        if levelOverride != nil {
            return levelOverride!
        }
        return store.scrollTimeLimit.wrappedValue
            .applyMapping(Mapping(a: 10, b: 0, c: 0, d: 3, clip: true))
    }
    var levelOverride: Double?
    var mainColor: Color {
        let h: Double = 259/360
        let s = level.applyMapping(Mapping(a: 0, b: 3, c: 0.2, d: 1, outWarp: .linear))
        let b = level.applyMapping(Mapping(a: 0, b: 3, c: 0.67, d: 0.4, outWarp: .linear))
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
        RoundedRectangle(cornerRadius: 60, style: .continuous)
    }
    
    var body: some View {
        let ratio = 1 - stateController.state.usagePoints / store.settings.usageMaxHp
        VStack {
            StagedDamageBar(
                ratio: ratio,
                height: 30
            )
            .padding(30)
            if expanded {
                HealSettings()
                    .padding(30)
            }
            if stateController.isSlowing {
                TimerLock { timeLeft in
                    ZStack (alignment: .topTrailing) {
                        HealButton(disabledOverride: timeLeft > 0)
                        if timeLeft > 0 {
                            Badge(timeLeft: timeLeft)
                                .offset(x: 25, y:-18)
                        }
                    }
                            .padding()
                            .frame(maxWidth: .infinity)
                }
            }
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
    }
}

struct HealSettings: View {
    @EnvironmentObject var store: SettingsStore
    @EnvironmentObject var controller: SettingsController
    
    @FocusState private var scrollTimeFocused: Bool
    @FocusState private var restTimeFocused: Bool
    
    
    private var baselineSpeedEnabled: Binding<Bool> {
        Binding {
            return store.settings.usageBaseRxSpeedTarget != 0.0
        } set: {
            if $0 {
                store.settings.usageBaseRxSpeedTarget = 1e6
            } else {
                store.settings.usageBaseRxSpeedTarget = 0
            }
        }
    }
    
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
                    .onChange(of: store.scrollTimeLimit.wrappedValue) { _ in
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
                    .onChange(of: store.restTime.wrappedValue) { _ in
                        controller.syncSettings()
                    }
            }
            VStack {
                Toggle("Set max speed", isOn: baselineSpeedEnabled)
                    .onChange(of: baselineSpeedEnabled.wrappedValue) { _ in
                        controller.syncSettings()
                    }
                    .tint(.purple)
                if baselineSpeedEnabled.wrappedValue {
                    SpeedBar(speed: $store.settings.usageBaseRxSpeedTarget, minSpeed: 40e3, maxSpeed: 10e6) {
                        controller.syncSettings()
                    }
                    .tint(.purple)
                }
            }
        }
    }
}

struct HealButton: View {
    var disabledOverride: Bool
    
    @EnvironmentObject var stateController: StateController

    var body: some View {
        let disabled = disabledOverride || !stateController.isSlowing
        let opacity = disabled ? 0.5 : 1
        Button("One more minute!") {
                stateController.heal()
            }
        .font(.system(.body))
        .padding()
        .foregroundColor(Color.white)
        .background(Color.accentColor.grayscale(1))
        .clipShape(RoundedRectangle(cornerRadius: 100, style:.continuous))
        .opacity(opacity)
        .disabled(disabled)
        .onTapGesture {
        }
        
    }
}

struct Badge: View {
    var timeLeft: Int
    var body: some View {
        Text("🔒 " + timeLeft.description)
            .frame(width: 60, height: 30)
            .foregroundColor(Color.white)
            .background(Color.accentColor.grayscale(1))
            .clipShape(Capsule())
    }
}

struct TimerLock<Content: View>: View{
    var content: (_ timeLeft: Int) -> Content
    @Environment(\.scenePhase) var scenePhase

    @State var timer = StateSubscriber.initializeTimer()
    @State var timeLeft: Int = 10
    
    static func initializeTimer() -> Publishers.Autoconnect<Timer.TimerPublisher> {
         return Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }

    var body: some View {
        content(timeLeft)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    startSubscription()
                } else {
                    timer.upstream.connect().cancel()
                }
            }
            .onAppear {
                startSubscription()
            }
            .onReceive(timer) {_ in
                if timeLeft == 0 {
                    timer.upstream.connect().cancel()
                    return
                }
                timeLeft -= 1
            }
    }
    
    func startSubscription() {
        timeLeft = 10
        timer = StateSubscriber.initializeTimer()
    }
}

struct ProgressiveModeView_Expanded: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ForEach([1, 5], id: \.self) { i in
                ProgressiveModeView(expanded: true)
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

struct ProgressiveModeView_Stacked: PreviewProvider {
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
