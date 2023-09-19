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
        Toggle("enable", isOn: deviceActivityController.instagram.shieldEnabled)

        Button("Instagram") { isPresented = true }
            .familyActivityPicker(isPresented: $isPresented,
                                  selection: $deviceActivityController.instagram.selection)
            .onChange(of: deviceActivityController.instagram.selection) { selection in
                deviceActivityController.instagram.store.shield.applications = selection.applicationTokens
            }
    }
}
