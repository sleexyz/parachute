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
        ZStack(alignment: .top) {
            HStack {
                Spacer()
                Button(action: {
                    scrollSessionViewController.setClosed()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 24, weight: .thin))
                        .padding()
                }
            }
            .padding(.top, 44)

            VStack {
                Spacer()
                Text("Do you want to keep scrolling?")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.bottom, 16)
                    .foregroundStyle(.black)

                HStack {
                    Spacer()
                    Button(action: {
                        startScrollSession()
                    }) {
                        Text("Start \(Int(Preset.scrollSession.overlayDurationSecs!  / 60)) minute session")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.parachuteOrange)
                    Spacer()
                    Button(action: {
                        scrollSessionViewController.setClosed()
                    }) {
                        Text("Never mind")
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.secondaryFill)
                    Spacer()
                }
                Spacer()
            }.frame(height: UIScreen.main.bounds.height)

        }
        .foregroundStyle(Color(.label))
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
