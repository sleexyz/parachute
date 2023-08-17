//
//  FilterDataProvider.swift
//  FilterDataProviderExtension
//
//  Created by Sean Lee on 8/15/23.
//

import FilterData
import NetworkExtension
// import Logger

class FilterDataProvider: NEFilterDataProvider {
    let dataFlowHandler: DataFlowHandler = DataFlowHandler()

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
        // Add code to initialize the filter.
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources.
        completionHandler()
    }

    override func handleRulesChanged() {
        return dataFlowHandler.handleRulesChanged()
        // Add code to deal with changes to the filter rules.
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        return dataFlowHandler.handleNewFlow(flow)
    }
}
