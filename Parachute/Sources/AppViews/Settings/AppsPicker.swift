import Controllers
import FamilyControls
import ManagedSettings
import ProxyService
import SwiftUI

struct AppsPicker: View {
    @EnvironmentObject var settingsController: SettingsController
    @EnvironmentObject var settingsStore: SettingsStore

    var body: some View {
        Section(header: Text("Apps")) {
            ForEach(AppController.apps, id: \.appType) { app in
                AppPicker(app: app)
                    .environmentObject(app.dac)
            }
        }
        .tint(.parachuteOrange)
    }
}

struct AppPicker: View {
    let app: AppController
    @EnvironmentObject var dac: AppDeviceActivityController
    @State var isPickerPresented = false

    @ViewBuilder
    var label: some View {
        Text(app.appType.name)
            .foregroundColor(.white)
    }

    var body: some View {
        HStack {
            Text(app.appType.name)
            Spacer()
            if !dac.isPaired {
                Button("Pair") {
                    isPickerPresented = true
                }
                .familyActivityPicker(isPresented: $isPickerPresented,
                                      selection: $dac.selection)
                .onChange(of: dac.selection) { selection in
                    dac.setTokens(selection.applicationTokens)
                }
            } else {
                Toggle(isOn: app.isEnabled) {
                    label
                }
            }
        }
    }
}

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
