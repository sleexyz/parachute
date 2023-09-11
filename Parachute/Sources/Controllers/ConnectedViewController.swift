//
//  ScrollSessionViewController.swift
//  slowdown
//
//  Created by Sean Lee on 8/11/23.
//

import DI
import Foundation
import OSLog
import SwiftUI

public enum ConnectedViewState {
    case main
    case settings
    case scrollSession
    case longSession
}

public enum SettingsPage {
    case main
    case advanced
}

public class ConnectedViewController: ObservableObject {
    public static var shared: ConnectedViewController = .init()
    public struct Provider: Dep {
        public func create(r _: Registry) -> ConnectedViewController {
            ConnectedViewController.shared
        }

        public init() {}
    }

    @Published public var state: ConnectedViewState = .main

    @Published public var settingsPage: SettingsPage = .main

    public var isAdvancedSettingsPresented: Binding<Bool> {
        Binding<Bool> {
            self.settingsPage == .advanced
        } set: { value in
            if value {
                self._setSettingsPage(page: .advanced)
            } else {
                self._setSettingsPage(page: .main)
            }
        }
    }

    public var isSettingsPresented: Binding<Bool> {
        Binding<Bool> {
            self.state == .settings
        } set: { value in
            if value {
                self._set(state: .settings)
            } else {
                self._set(state: .main)
            }
        }
    }

    public var isScrollSessionPresented: Binding<Bool> {
        Binding<Bool> {
            self.state == .scrollSession
        } set: { value in
            if value {
                self._set(state: .scrollSession)
            } else {
                self._set(state: .main)
            }
        }
    }

    private let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "ConnectedViewController")

    @MainActor
    public func set(state: ConnectedViewState) {
        _set(state: state)
    }

    private func _set(state: ConnectedViewState) {
        self.state = state
        if state != .settings {
            settingsPage = .main
        }
    }

    @MainActor
    public func setSettingsPage(page: SettingsPage) {
        _setSettingsPage(page: page)
    }

    private func _setSettingsPage(page: SettingsPage) {
        settingsPage = page
    }
}
