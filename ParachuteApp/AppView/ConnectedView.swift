//
//  ConnectedView.swift
//  slowdown
//
//  Created by Sean Lee on 2/15/23.
//

import AppViews
import CommonViews
import Controllers
import Foundation
import OrderedCollections
import ProxyService
import SwiftUI

struct ProfileCardModifier: ViewModifier {
    @EnvironmentObject var profileManager: ProfileManager

    func body(content: Content) -> some View {
        content
    }
}

struct ConnectedView: View {
    @EnvironmentObject var connectedViewController: ConnectedViewController

    var body: some View {
        MainView()
            .sheet(isPresented: connectedViewController.isLongSessionPresented) {
                LongSessionView()
                    .padding(.top, 20)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .background(LinearGradient.bg)
    }
}

struct ConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedPreviewContext {
            ConnectedView()
                .consumeDep(NEConfigurationService.self) { service in
                    service.isConnected = true
                }
        }
    }
}

struct ConnectedViewSession_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedPreviewContext {
            ConnectedView()
                .consumeDep(NEConfigurationService.self) { service in
                    service.isConnected = true
                }
                .consumeDep(ProfileManager.self) { profileManager in
                    Task { @MainActor in
                        try await profileManager.loadPreset(
                            preset: .focus,
                            overlay: .quickBreak
                        )
                    }
                }
        }
    }
}

struct ConnectedViewSettings_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedPreviewContext {
            ConnectedView()
                .consumeDep(ConnectedViewController.self) { connectedViewController in
                    connectedViewController.set(state: .settings)
                }
        }
    }
}

struct ConnectedViewSchedule_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedPreviewContext {
            ConnectedView()
                .consumeDep(ConnectedViewController.self) { connectedViewController in
                    connectedViewController.set(state: .settings)
                    connectedViewController.setSettingsPage(page: .schedule)
                }
        }
    }
}

struct ConnectedViewLong_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedPreviewContext {
            ConnectedView()
                .consumeDep(ConnectedViewController.self) { connectedViewController in
                    connectedViewController.set(state: .longSession)
                }
        }
    }
}
