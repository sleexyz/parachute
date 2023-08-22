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
import OSLog
import Models

public class FilterDataProvider: NEFilterDataProvider {
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "FilterDataProvider")


    lazy var dataFlowController: DataFlowController = {
        // TODO: load settings from disk
        // return DataFlowController(settings: (try? SettingsHelper.loadSettings()) ?? .defaultSettings)
        return DataFlowController(settings: .defaultSettings)
    }()

    var observerContext = 0
    public override init() {
        super.init()
        // FirebaseApp.configure()
        self.addObserver(self, forKeyPath: "filterConfiguration", options: [.initial, .new], context: &observerContext)
    }
    
    /// Observe changes to the configuration.
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "filterConfiguration" && context == &observerContext {
            logger.info("configuration changed")
            guard let requestData = self.filterConfiguration.vendorConfiguration?[.vendorConfigurationKey] as? Data else {
                return
            }
            guard let request = try? Proxyservice_Request(serializedData: requestData) else {
                return
            }
            if case(.setSettings(let setSettings)) = request.message {
                dataFlowController.updateSettings(settings: setSettings)
            }
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
        let verdict = dataFlowController.handleNewFlow(flow)
        if let flow = flow as? NEFilterSocketFlow {
            logger.info("new flow verdict for \(flow, privacy: .public): \(verdict, privacy: .public)")
        }
        return verdict
    }
    
    public override func handleInboundData(from flow: NEFilterFlow, readBytesStartOffset offset: Int, readBytes: Data) -> NEFilterDataVerdict {
        let verdict = dataFlowController.handleInboundData(from: flow, offset: offset, readBytes: readBytes)
        // if let flow = flow as? NEFilterSocketFlow {
        //     logger.info("inbound data flow verdict for \(flow.remoteHostname ?? "", privacy: .public): \(verdict, privacy: .public)")
        // }
        return verdict
    }
}
