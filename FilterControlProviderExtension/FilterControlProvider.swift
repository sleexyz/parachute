//
//  FilterControlProvider.swift
//  FilterControlProviderExtension
//
//  Created by Sean Lee on 8/15/23.
//
// NOTE: This is currently unused.

import FilterControl
import NetworkExtension
import Common

class FilterControlProvider: NEFilterControlProvider {
    let controlFlowHandler = ControlFlowHandler()
	var observerContext = 0
//
    override init() {
        super.init()
        self.addObserver(self, forKeyPath: "filterConfiguration", options: [.initial, .new], context: &observerContext)
    }


    /// Observe changes to the configuration.
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "filterConfiguration" && context == &observerContext {
            NSLog("configuration changed")
		} else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
    
    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Add code to initialize the filter
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow, completionHandler: @escaping (NEFilterControlVerdict) -> Void) {
        // Add code to determine if the flow should be dropped or not, downloading new rules if required
        let verdict = controlFlowHandler.handleNewFlow(flow)
        completionHandler(verdict)
    }

}
