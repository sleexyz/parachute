//
//  SettingsController.swift
//  slowdown
//
//  Created by Sean Lee on 12/18/22.
//

import DI
import Foundation
import ProxyService
import SwiftProtobuf
import SwiftUI

// Operations for changing settings
public class SettingsController: ObservableObject {
    public struct Provider: Dep {
        public func create(r: Registry) -> SettingsController {
            SettingsController(
                store: r.resolve(SettingsStore.self),
                service: r.resolve(NEConfigurationService.self)
            )
        }

        public init() {}
    }

    private let store: SettingsStore
    private let service: any NEConfigurationServiceProtocol

    init(store: SettingsStore, service: any NEConfigurationServiceProtocol) {
        self.store = store
        self.service = service
    }

    public func switchMode(mode: Proxyservice_Mode) {
        if mode != store.activePreset.mode {
            store.activePresetBinding.wrappedValue.mode = mode
            Task(priority: .background) {
                try await syncSettings()
            }
        }
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
        try store.save()
        try await service.SetSettings(settings: store.settings)
        // try self.store.save()
    }
}
