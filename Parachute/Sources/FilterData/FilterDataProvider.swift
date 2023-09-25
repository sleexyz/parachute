//
//  FilterDataProvider.swift
//  FilterDataProviderExtension
//
//  Created by Sean Lee on 8/15/23.
//

import Common
import FilterCommon
import Models
import NetworkExtension
import OSLog
import ProxyService
import SwiftProtobuf

public class FilterDataProvider: NEFilterDataProvider {
    let logger: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "FilterDataProvider")

    lazy var dataFlowController: DataFlowController = {
        // TODO: load settings from disk
        // return DataFlowController(settings: (try? SettingsHelper.loadSettings()) ?? .defaultSettings)
        DataFlowController(settings: .defaultSettings)
    }()

    var observerContext = 0
    override public init() {
        super.init()
        // FirebaseApp.configure()
        addObserver(self, forKeyPath: "filterConfiguration", options: [.initial, .new], context: &observerContext)
    }

    /// Observe changes to the configuration.
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "filterConfiguration", context == &observerContext {
            logger.info("configuration changed")
            guard let requestData = filterConfiguration.vendorConfiguration?[.vendorConfigurationKey] as? Data else {
                return
            }
            guard let request = try? Proxyservice_Request(serializedData: requestData) else {
                return
            }
            if case let .setSettings(setSettings) = request.message {
                dataFlowController.updateSettings(settings: setSettings)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    override public func startFilter(completionHandler: @escaping (Error?) -> Void) {
        logger.info("Starting FilterDataProvider")
        // Add code to initialize the filter.
        completionHandler(nil)
    }

    override public func stopFilter(with _: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        logger.info("Stopping FilterDataProvider")
        // Add code to clean up filter resources.
        completionHandler()
    }

    override public func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        // logger.debug("Received new flow for \(flow.sourceAppIdentifier ?? "", privacy: .public)")
        let verdict = dataFlowController.handleNewFlow(flow)
        return verdict
    }

    override public func handleInboundData(from flow: NEFilterFlow, readBytesStartOffset offset: Int, readBytes: Data) -> NEFilterDataVerdict {
        let verdict = dataFlowController.handleInboundData(from: flow, offset: offset, readBytes: readBytes)
        #if DEBUG
            if flow.matchSocialMedia() != nil {
                if let flow = flow as? NEFilterSocketFlow {
                    EndpointHistogram.recordInboundBytes(flow: flow, bytes: readBytes.count)
                }
                if let flow = flow as? NEFilterBrowserFlow {
                    logger.debug("new browser flow: \(flow.parentURL?.absoluteString ?? "", privacy: .public): \(flow.request?.url?.absoluteString ?? "", privacy: .public)")
                }
            }
        #endif
        return verdict
    }

    override public func handleOutboundData(from flow: NEFilterFlow, readBytesStartOffset _: Int, readBytes: Data) -> NEFilterDataVerdict {
        #if DEBUG
            if flow.matchSocialMedia() != nil {
                if let flow = flow as? NEFilterSocketFlow {
                    EndpointHistogram.recordOutboundBytes(flow: flow, bytes: readBytes.count)
                }
            }
        #endif
        return NEFilterDataVerdict(passBytes: readBytes.count, peekBytes: 128 * 1024 * 1024)
    }

    override public func handleInboundDataComplete(for flow: NEFilterFlow) -> NEFilterDataVerdict {
        let verdict = dataFlowController.handleInboundDataComplete(for: flow)
        return verdict
    }
}
