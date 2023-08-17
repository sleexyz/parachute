//
//  FilterControlProvider.swift
//  FilterControlProviderExtension
//
//  Created by Sean Lee on 8/15/23.
//

import FilterControl
import NetworkExtension
// import Common

class FilterControlProvider: NEFilterControlProvider {
    let controlFlowHandler = ControlFlowHandler()
    // let filterConfigurationUpdateHandler = FilterConfigurationUpdateHandler()

    // var kvoToken: NSKeyValueObservation?

    // override init() {
    //     // CommonLogging.initialize()
    //     super.init()
    //     // self.filterConfigurationUpdateHandler.registerProvider(provider: self)
    //     // self.addObserver(self, forKeyPath: "filterConfiguration", options: [.initial, .new], context: &observerContext)
    //     // kvoToken = self.observe(\.filterConfiguration, options: [.initial, .new]) { (person, change) in
    //     //     // guard let filterConfiguration = change.new else { return }
    //     //     self.filterConfigurationUpdateHandler.update(filterConfiguration: self.filterConfiguration)
    //     // }
    // }

    // deinit {
    //     kvoToken?.invalidate()
    // }

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
