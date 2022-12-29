//
//  AppView.swift
//  slowdown
//
//  Created by Sean Lee on 4/28/22.
//

import SwiftUI
import NetworkExtension
import Combine
import func os.os_log
import ProxyService
import Intents

final class AppViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var logSpeed: Double
    @Published var debug = false
    @Published var isShowingError = false
    @Published private(set) var errorTitle = ""
    @Published private(set) var errorMessage = ""
    private var bag = [AnyCancellable]()
    let service: VPNConfigurationService
    let cheatController: CheatController
    let settingsController: SettingsController
    let store: SettingsStore
    
    
    init(service: VPNConfigurationService = .shared, cheatController: CheatController = .shared, settingsController: SettingsController = .shared, settingsStore: SettingsStore = .shared) {
        self.service = service
        self.cheatController = cheatController
        self.settingsController = settingsController
        self.store = settingsStore
        logSpeed = log(settingsStore.settings.baseRxSpeedTarget)
        $logSpeed.sink {
            settingsStore.settings.baseRxSpeedTarget = exp($0)
        }.store(in: &bag)
    }
    
    func toggleConnection() {
        if service.isConnected {
            Task {
                do {
                    try await service.stopConnection()
                } catch {
                    self.showError(
                        title: "Failed to stop VPN tunnel",
                        message: error.localizedDescription
                    )
                }
            }
            return
        }
        
        Task {
            do {
                try await self.service.startConnection(debug: self.debug)
            } catch {
                self.showError(
                    title: "Failed to start VPN tunnel",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    @MainActor
    func setCurrentIndex(value: Int) {
        self.currentIndex = value
    }
    
    func startCheat() {
        Task {
            do {
                try await self.cheatController.addCheat()
                await setCurrentIndex(value: 1)
            } catch {
                self.showError(
                    title: "Failed to start cheat",
                    message: error.localizedDescription
                )
            }
        }
    }
    
    func stopCheat() {
            Task {
                do {
                    try await self.cheatController.stopCheat()
                    await setCurrentIndex(value: 0)
                } catch {
                    self.showError(
                        title: "Failed to stop cheat",
                        message: error.localizedDescription
                    )
                }
            }
    }
    
    
    private func showError(title: String, message: String) {
        self.errorTitle = title
        self.errorMessage = message
        self.isShowingError = true
    }
}

struct SnapCarousel<Content: View>: View {
    var content: (Mode) -> Content
    var list: [Mode]
    
    // Properties....
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    init(spacing: CGFloat = 0, trailingSpace: CGFloat = 0, index: Binding<Int>, items: [Mode], @ViewBuilder content: @escaping (Mode)->Content){
        
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    // Offset...
    @GestureState var gestureOffset: CGFloat = 0
    @State var programmaticOffset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    @State var animationCompleteTimer: Timer?
    
    var body: some View {
        GeometryReader{proxy in
            let width = proxy.size.width - ( trailingSpace - spacing )
            HStack (spacing: spacing) {
                ForEach(list) { item in
                    content(item)
                    // .frame(width: proxy.size.width - trailingSpace)
                        .frame(width: UIScreen.main.bounds.size.width / 2, height: UIScreen.main.bounds.size.height/2)

                }

            }
            // To make the edges draggable
            .background(Color.white)
            .padding(.horizontal, spacing)
            .offset(x: (CGFloat(currentIndex) * -width) + gestureOffset + programmaticOffset)
            .onChange(of: self.index) { _ in
                if currentIndex != index {
                    programmaticOffset = CGFloat(index - currentIndex) * -width
                    self.animationCompleteTimer?.invalidate()
                    self.animationCompleteTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {_ in
                        currentIndex = index
                        programmaticOffset = 0
                        
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 8, coordinateSpace: .local)
                    .updating($gestureOffset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded({ value in
                        let offsetX = value.translation.width
                        if abs(offsetX) < 50 {
                            return
                        }
                        if offsetX > 0 {
                            currentIndex = max(min(currentIndex - 1, list.count - 1), 0)
                        }
                        if offsetX < 0 {
                            currentIndex = max(min(currentIndex + 1, list.count - 1), 0)
                        }
                        if index != currentIndex {
                            list[currentIndex].onEnter()
                        }
                        index = currentIndex
                    })
            )
            
        }
        .animation(.interpolatingSpring(mass: 0.1, stiffness: 20, damping: 2), value: programmaticOffset)
        .animation(.interpolatingSpring(mass: 0.1, stiffness: 20, damping: 2), value: gestureOffset)
//        .animation(.easeInOut(duration: 0.5), value: offset)
        
    }

}

struct Mode: Identifiable {
    var id: String
    var onEnter : () -> Void
}

struct AppView: View {
    @ObservedObject var model: AppViewModel
    @ObservedObject var store: SettingsStore
    @ObservedObject var service: VPNConfigurationService
    @ObservedObject var cheatController: CheatController
    var controller: SettingsController = .shared
    
    @State var modes: [Mode]

    
    init(model: AppViewModel, store: SettingsStore = .shared, service: VPNConfigurationService = .shared, cheatController: CheatController = .shared, controller: SettingsController = .shared) {
        self.model = model
        self.store = store
        self.service = service
        self.cheatController = cheatController
        self.controller = controller
        self.modes = [
            Mode(id:"focus", onEnter: {
                model.stopCheat()
            }),
            Mode(id:"break", onEnter: {
                model.startCheat()
            }),
        ]
    }
    
    var breakModeCarouselItem: some View {
            var title = ""
        let t = Int(cheatController.sampledCheatTimeLeft.rounded(.up))
            let min = t / 60
            let sec = t % 60
            if min > 0 {
                title += "\(min)m"
            }
            if sec > 0 {
                if title != "" {
                    title += " "
                }
                title += "\(sec)s"
            }
            return ZStack(alignment: .top) {
                // TODO: this button eats up the drag gesture
//                Button(action: model.startCheat) {
                    Text("🤤")
//                }
                .font(.system(size: 144))
                .padding()
                .frame(maxWidth: .infinity)
                Text(title).padding().offset(x: 0, y: 200)
            }
        
    }
    
    @ViewBuilder
    var focusModeCarouselItem: some View {
        ZStack(alignment: .top) {
            Text("😎")
                .font(.system(size: 144))
                .padding()
                .frame(maxWidth: .infinity)
        }
    }
    
    var appModeCarousel: some View {
        return AnyView(SnapCarousel(
            spacing: UIScreen.main.bounds.size.width / 4,
            trailingSpace: UIScreen.main.bounds.size.width / 2,
            index: $model.currentIndex, items:modes
        ){mode in
            if mode.id == "focus" {
                focusModeCarouselItem
            } else {
                breakModeCarouselItem
            }
        }).onChange(of: cheatController.isCheating) {value in
            model.currentIndex = value ? 1 : 0
        }
    }
    
    // TODO: get this to animate
    var appModeSelector: some View {
        return VStack {
            Spacer()
            Spacer()
            HStack{
                Button(action: model.stopCheat) {
                    Text("😎")
                        .font(.system(size: 24))
                }
                        .padding(8)
                    .background(!cheatController.isCheating ? Color.black.opacity(0.1): nil)
                    .cornerRadius(24)
                Button(action: model.startCheat) {
                    Text("🤤")
                        .font(.system(size: 24))
                }
                .padding(8)
                    .background(cheatController.isCheating ? Color.black.opacity(0.1): nil)
                    .cornerRadius(24)
            }
            .frame(maxWidth: .infinity)
            Spacer()
        }
    }
    
    var body: some View {
        VStack{
            if !service.isConnected {
                VStack {
                    PrimaryButton(title: "Start", action: model.toggleConnection, isLoading: service.isTransitioning)
                    Spacer()
                    Toggle(isOn: $model.debug, label: { Text("Debug")})
                        .disabled(service.isTransitioning)
                }.padding()
            } else {
                VStack {
                    PrimaryButton(title: "Stop", action: model.toggleConnection, isLoading: service.isTransitioning)
                    VStack {
                        Slider(
                            value: $model.logSpeed,
                            in: (11...16),
                            onEditingChanged: { editing in
                                if !editing {
                                    controller.syncSettings()
                                }
                            }
                        )
                        Text("\(Int(store.settings.baseRxSpeedTarget))")
                    }
                }.padding()
                Spacer()
                appModeCarousel
                Spacer()
                appModeSelector
                Spacer()
            }
        }
        .disabled(service.isTransitioning)
        .alert(isPresented: $model.isShowingError) {
            Alert(
                title: Text(self.model.errorTitle),
                message: Text(self.model.errorMessage),
                dismissButton: .cancel()
            )
        }
        .navigationBarItems(trailing:
                                Spinner(isAnimating: service.isTransitioning, color: .label, style: .medium)
        )
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppViewModel()
        let service = MockVPNConfigurationService(store: .shared)
        service.setIsConnected(value: true)
        return  AppView(model: appModel, service: service)
    }
}
