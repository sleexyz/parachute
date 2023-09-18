
import Foundation
import NetworkExtension
import OSLog


// Goal:
// - lightweight way to get insight into what flows are for what
// - so we can block e.g. just the feed and not messaging and events / stories
//
// Data collected
// - 1) Track total bytes
// - 1) bytes per second
// - 1) frecency points
//
// Data surfaced
// - Top flows per app
class EndpointHistogram {
    var lastPrinted: Date = Date()

    static var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "EndpointHistogram")

    private var flows: [NWEndpoint: EndpointHistogramEntry] = [:]

    static let instagram = EndpointHistogram()
    static let tiktok = EndpointHistogram()
    static let twitter = EndpointHistogram()
    static let youtube = EndpointHistogram()
    static let facebook = EndpointHistogram()

    static func recordInboundBytes(flow: NEFilterSocketFlow, bytes: Int) {
        guard let histogram = getInstance(flow: flow) else {
            return
        }
        guard let endpoint = flow.remoteEndpoint else {
            logger.log("No endpoint found")
            return
        }
        logger.log("inbound local: \(flow.localEndpoint.debugDescription)")
        
        histogram.recordInboundBytes(flow: flow, bytes: bytes)
    }

    static func recordOutboundBytes(flow: NEFilterSocketFlow, bytes: Int) {
        guard let histogram = getInstance(flow: flow) else {
            return
        }

        
        histogram.recordOutboundBytes(flow: flow, bytes: bytes)
    }

    static func getInstance(flow: NEFilterFlow) -> EndpointHistogram? {
        switch flow.matchSocialMedia()?.appType {
        case .instagram:
            return instagram
        case .tiktok:
            return tiktok
        case .twitter:
            return twitter
        case .youtube:
            return youtube
        default:
            return nil
        }
    }
    
    public func recordOutboundBytes(flow: NEFilterSocketFlow, bytes: Int) {
        guard let endpoint = flow.remoteEndpoint else {
            EndpointHistogram.logger.log("No endpoint found")
            return
        }
        let sampleTime = Date()
        updateFlow(direction: .outbound, sampleTime: sampleTime, endpoint: endpoint, bytes: bytes, hostname: flow.remoteHostname)
//        if sampleTime.timeIntervalSince(lastPrinted) > 1 {
//            printSummary()
//            lastPrinted = sampleTime
//        }
    }

    public func recordInboundBytes(flow: NEFilterSocketFlow, bytes: Int) {
        guard let endpoint = flow.remoteEndpoint else {
            EndpointHistogram.logger.log("No endpoint found")
            return
        }

        let sampleTime = Date()
        updateFlow(direction: .inbound, sampleTime: sampleTime, endpoint: endpoint, bytes: bytes, hostname: flow.remoteHostname)
        if sampleTime.timeIntervalSince(lastPrinted) > 1 {
            printSummary()
            //EndpointHistogram.logger.log("inbound local: \(flow.localEndpoint.debugDescription, privacy: .public)")
            lastPrinted = sampleTime
        }
    }

    func updateFlow(direction: Direction, sampleTime: Date, endpoint: NWEndpoint, bytes: Int, hostname: String?) {
        if flows[endpoint] == nil {
            flows[endpoint] = EndpointHistogramEntry(endpoint: endpoint, hostname: hostname)
        }
        
        guard var flow = flows[endpoint] else {
            // Unexpected error
            return
        }
        defer {
            flows[endpoint] = flow
        }
        
        if direction == .inbound {
            flow.rxBytes += bytes
        } else {
            flow.txBytes += bytes
        }
        flow.lastUpdated = sampleTime
    }
    
    func printSummary() {
        // sort by most recent
        let sortedFlows = flows.values.sorted { $0.lastUpdated > $1.lastUpdated }
        // let sortedFlows = flows.values.sorted { $0.totalBytes > $1.totalBytes }
        var str = ""
        for flow in sortedFlows {
            str += "\(flow.endpoint) \(flow.hostname ?? "") \n rxBytes \(flow.rxBytes)\n txBytes \(flow.txBytes)\n"
        }
        EndpointHistogram.logger.info("\(str, privacy: .public)")
    }

}

enum Direction {
    case inbound
    case outbound
}

struct EndpointHistogramEntry {
    var endpoint: NWEndpoint
    var hostname: String? = nil
    var rxBytes: Int = 0
    var txBytes: Int = 0
    var lastUpdated: Date = Date()

}
