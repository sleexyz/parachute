//
//  FilterDataProvider.swift
//  FilterDataProviderExtension
//
//  Created by Sean Lee on 8/15/23.
//

import FilterData
import NetworkExtension

class FilterDataProvider: NEFilterDataProvider {
    let dataFlowHandler: DataFlowHandler = DataFlowHandler()

    override init() {
        super.init()
    }

    override func startFilter(completionHandler: @escaping (Error?) -> Void) {
        // Add code to initialize the filter.
        completionHandler(nil)
    }
    
    override func stopFilter(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code to clean up filter resources.
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        return dataFlowHandler.handleNewFlow(flow)
    }
}
