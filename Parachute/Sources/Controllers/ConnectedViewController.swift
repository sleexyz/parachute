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

public class ConnectedViewController: ObservableObject {
    public static var shared: ConnectedViewController = .init()
    public struct Provider: Dep {
        public func create(r _: Registry) -> ConnectedViewController {
            return ConnectedViewController.shared
        }

        public init() {}
    }

    @Published public var state: ConnectedViewState = .main

    public var isSettingsPresented: Binding<Bool> {
        Binding<Bool> {
            self.state == .settings
        } set: { value in
            if value {
                self.state = .settings
            } else {
                self.state = .main
            }
        }
    }

    public var isScrollSessionPresented: Binding<Bool> {
        Binding<Bool> {
            self.state == .scrollSession
        } set: { value in
            if value {
                self.state = .scrollSession
            } else {
                self.state = .main
            }
        }
    }

    private let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "ConnectedViewController")

    @MainActor
    public func set(state: ConnectedViewState) {
        self.state = state
    }
}
