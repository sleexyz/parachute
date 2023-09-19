import Controllers
import FamilyControls
import ManagedSettings
import SwiftUI

public struct AppPicker: View {
    @State var isPresented = false
    @EnvironmentObject var deviceActivityController: DeviceActivityController

    public init() {}

    public var body: some View {
//        Button {
//            deviceActivityController.initiateMonitoring()
//        } label: {
//            Text("Initiate Monitoring")
//        }
//        Button {
//            deviceActivityController.stopMonitoring()
//        } label: {
//            Text("Stop Monitoring")
//        }
//        
        Toggle("enable", isOn: deviceActivityController.shieldEnabled)

        Button("Pair Instagram") { isPresented = true }
            .familyActivityPicker(isPresented: $isPresented,
                                  selection: $deviceActivityController.instagram.selection)
            .onChange(of: deviceActivityController.instagram.selection) { selection in
                deviceActivityController.instagram.setTokens(selection.applicationTokens)
            }

        Button("Pair Tiktok") { isPresented = true }
            .familyActivityPicker(isPresented: $isPresented,
                                  selection: $deviceActivityController.tiktok.selection)
            .onChange(of: deviceActivityController.tiktok.selection) { selection in
                deviceActivityController.tiktok.setTokens(selection.applicationTokens)
            }
    }
}
