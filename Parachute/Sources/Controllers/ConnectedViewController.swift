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

public enum ScrollSessionPage {
    case main
    case sessionSettings
}

public enum SettingsPage {
    case main
    case advanced
    case schedule
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
    @Published public var scrollSessionPage: ScrollSessionPage = .main

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

    public var isSchedulePresented: Binding<Bool> {
        Binding<Bool> {
            self.settingsPage == .schedule
        } set: { value in
            if value {
                self._setSettingsPage(page: .schedule)
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

    public var isSessionSettingsPresented: Binding<Bool> {
        Binding<Bool> {
            self.scrollSessionPage == .sessionSettings
        } set: { value in
            if value {
                self._setScrollSessionPage(page: .sessionSettings)
            } else {
                self._setScrollSessionPage(page: .main)
            }
        }
    }

    public var isLongSessionPresented: Binding<Bool> {
        Binding<Bool> {
            self.state == .longSession
        } set: { value in
            if value {
                self._set(state: .longSession)
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

    @MainActor
    public func setScrollSessionPage(page: ScrollSessionPage) {
        _setScrollSessionPage(page: page)
    }

    private func _setScrollSessionPage(page: ScrollSessionPage) {
        scrollSessionPage = page
    }
}
