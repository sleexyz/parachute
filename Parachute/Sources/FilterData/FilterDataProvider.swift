//
//  FilterDataProvider.swift
//  FilterDataProviderExtension
//
//  Created by Sean Lee on 8/15/23.
//

import NetworkExtension
import Common
import SwiftProtobuf
import ProxyService
import Logging
import Models

public class FilterDataProvider: NEFilterDataProvider {
    let logger: Logger = {
        CommonLogging.initialize()
        return Logger(label: "industries.strange.slowdown.FilterDataProvider")
    }()

    lazy var dataFlowController: DataFlowController = {
        return DataFlowController(settings: self.settings ?? .defaultSettings)
    }()

    var observerContext = 0
    public override init() {
        super.init()
        self.addObserver(self, forKeyPath: "filterConfiguration", options: [.initial, .new], context: &observerContext)
    }
    
    var settings: Proxyservice_Settings? {
        guard let settingsData = self.filterConfiguration.vendorConfiguration?[.vendorConfigurationKey] as? Data else {
            return nil
        }
        return try? Proxyservice_Settings(serializedData: settingsData)
    }


    /// Observe changes to the configuration.
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "filterConfiguration" && context == &observerContext {
            if let settings = self.settings {
                dataFlowController.updateSettings(settings: settings)
            }
            logger.info("configuration changed")
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    public override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Add code to initialize the filter.
        completionHandler(nil)
    }
    
    public override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources.
        completionHandler()
    }

    public override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        return dataFlowController.handleNewFlow(flow)
    }
}
