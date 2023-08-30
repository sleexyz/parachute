//
//  ScrollSessionViewController.swift
//  slowdown
//
//  Created by Sean Lee on 8/11/23.
//

import Foundation
import DI
import OSLog
import SwiftUI

public enum ConnectedViewState {
    case main
    case settings
    case scrollSession
    case longSession
}

public class ConnectedViewController: ObservableObject  {
    public static var shared: ConnectedViewController = ConnectedViewController()
    public struct Provider: Dep {
        public func create(r: Registry) -> ConnectedViewController  {
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

    private let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ConnectedViewController")

    @MainActor
    public func set(state: ConnectedViewState) {
        self.state = state
    }
}
