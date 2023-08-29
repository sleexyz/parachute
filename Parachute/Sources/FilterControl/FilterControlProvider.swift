//
//  FilterControlProvider.swift
//  FilterControlProviderExtension
//
//  Created by Sean Lee on 8/15/23.
//
// NOTE: This is currently unused.

import NetworkExtension
import Common
import Firebase
import OSLog
import FilterCommon
import ProxyService
import Models

class FilterControlProvider: NEFilterControlProvider {
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "FilterControlProvider")

    var lastUpdated: Date = Date()

    var settings: Proxyservice_Settings = .defaultSettings

	var observerContext = 0
    override init() {
        super.init()
        FirebaseApp.configure()
        self.addObserver(self, forKeyPath: "filterConfiguration", options: [.initial, .new], context: &observerContext)
    }

    /// Observe changes to the configuration.
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "filterConfiguration" && context == &observerContext {
            logger.info("configuration changed")
            guard let requestData = self.filterConfiguration.vendorConfiguration?[.vendorConfigurationKey] as? Data else {
                return
            }
            guard let request = try? Proxyservice_Request(serializedData: requestData) else {
                return
            }
            if case(.setSettings(let setSettings)) = request.message {
                self.settings = setSettings
            }
		} else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
    
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        logger.info("Starting FilterControlProvider")
        // Add code to initialize the filter
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        logger.info("Stopping FilterControlProvider")
        // Add code to clean up filter resources
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow, completionHandler: @escaping (NEFilterControlVerdict) -> Void) {
        guard let app = flow.matchSocialMedia() else {
            completionHandler(.allow(withUpdateRules: false))
            return
        }
        if settings.isInScrollSession {
            completionHandler(.updateRules())
            return
        }
        // logger.info("New slowed flow: \(flow.identifier, privacy: .public)")
        // Task {
            let now = Date()
            // guard now.timeIntervalSince(lastUpdated) > 1e-3 else {
            //     logger.info("Delaying update rules")
            //     return
            // }

            // try await Task.sleep(nanoseconds: 1_000_000)
            lastUpdated = Date()
            logger.info("Done! \(flow.identifier, privacy: .public)")
            completionHandler(.updateRules())
        // }
     }

}
