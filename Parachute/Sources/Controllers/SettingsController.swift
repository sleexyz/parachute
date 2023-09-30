//
//  SettingsController.swift
//  slowdown
//
//  Created by Sean Lee on 12/18/22.
//

import DI
import Foundation
import OSLog
import ProxyService
import SwiftProtobuf
import SwiftUI

// Operations for changing settings
public class SettingsController: ObservableObject {
    public struct Provider: Dep {
        public func create(r _: Registry) -> SettingsController {
            .shared
        }

        public init() {}
    }

    public static let shared: SettingsController = .init(store: SettingsStore.shared, service: NEConfigurationService.shared)

    private let store: SettingsStore
    private let service: any NEConfigurationServiceProtocol

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SettingsController")

    init(store: SettingsStore, service: any NEConfigurationServiceProtocol) {
        self.store = store
        self.service = service
    }

    @MainActor
    func setSettings(_ op: (_ settings: inout Proxyservice_Settings) -> Void) async throws {
        op(&store.settings)
        if service.isConnected {
            try await service.SetSettings(settings: store.settings)
        }
        try store.save()
    }

    @MainActor
    public func syncSettings(reason: String = "") async throws {
        store.settings.changeMetadata = Proxyservice_ChangeMetadata.with {
            $0.id = SettingsStore.id
            $0.reason = reason
            $0.timestamp = Google_Protobuf_Timestamp(date: Date())
        }
        do {
            try store.save()
        } catch {
            logger.error("Failed to save settings: \(error, privacy: .public)")
        }
        // do {
        //     try await service.SetSettings(settings: store.settings)
        // } catch {
        //     logger.error("Failed to upstream settings: \(error)")
        // }
    }

    public func forceRefresh() {
        Task { @MainActor in
            try await self.syncSettings(reason: "force refresh")
        }
    }
}
