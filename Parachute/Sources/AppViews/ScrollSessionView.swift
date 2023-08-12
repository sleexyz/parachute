import SwiftUI
import DI
import Controllers
import AppHelpers
import CommonViews
import Models

public struct ScrollSessionView: View {
    public init() {}

    @EnvironmentObject var scrollSessionViewController: ScrollSessionViewController
    @EnvironmentObject var profileManager: ProfileManager
    
    public func startScrollSession() {
        Task { @MainActor in
            try await profileManager.loadPreset(
                preset: .focus,
                overlay: .scrollSession
            )
            if #available(iOS 16.2, *) {
                await ActivitiesHelper.shared.update(settings: SettingsStore.shared.settings)
            }
            scrollSessionViewController.setClosed()
        }
    }

    public var body: some View {
        
        TimerLock(duration: 10) { timeLeft in
            if timeLeft > 0 {
                Text("Take a deep breath...")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.bottom, 16)
                    .foregroundStyle(Color(UIColor.label))
                    .transition(.opacity.animation(.default))
            } else {
                VStack {
                    Spacer()
                    Text("Do you want to keep scrolling?")
                        .font(.system(size: 24, weight: .bold))
                        .padding(.bottom, 16)
                        .foregroundStyle(Color(UIColor.label))
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            startScrollSession()
                        }) {
                            Image(systemName: "play.fill")
                            Text("\(Int(Preset.scrollSession.overlayDurationSecs!  / 60)) minutes")
                        }
                        .buttonStyle(.bordered)
                        .tint(.parachuteOrange)
                        Spacer()
                        Button(action: {
                            scrollSessionViewController.setClosed()
                        }) {
                            Text("Never mind")
                        }
                        .buttonStyle(.bordered)
                        .tint(.secondaryFill)
                        Spacer()
                    }
                    Spacer()
                }
                .transition(.opacity.animation(.default))
            }
        }
        .frame(height: UIScreen.main.bounds.height)
        .buttonBorderShape(.capsule)
    }

}

struct ScrollSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollSessionView()
            .provideDeps([
                ScrollSessionViewController.Provider()
            ])
    }
}
