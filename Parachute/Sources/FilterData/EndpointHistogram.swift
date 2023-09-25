
import Foundation
import NetworkExtension
import OSLog
import ProxyService

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
    var lastPrinted: Date = .init()

    let appType: Proxyservice_AppType
    public init(appType: Proxyservice_AppType) {
        self.appType = appType
    }

    static var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "EndpointHistogram")

    private var flows: [NWEndpoint: EndpointHistogramEntry] = [:]

    static let instagram = EndpointHistogram(appType: .instagram)
    static let tiktok = EndpointHistogram(appType: .tiktok)
    static let twitter = EndpointHistogram(appType: .twitter)
    static let youtube = EndpointHistogram(appType: .youtube)
    static let facebook = EndpointHistogram(appType: .facebook)

    static func recordInboundBytes(flow: NEFilterSocketFlow, bytes: Int) {
        guard let histogram = getInstance(flow: flow) else {
            return
        }
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
            instagram
        case .tiktok:
            tiktok
        case .twitter:
            twitter
        case .youtube:
            youtube
        case .facebook:
            facebook
        default:
            nil
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
            // Only update on TX
            flow.lastUpdated = sampleTime
        }
        if hostname != nil {
            flow.hostname = hostname
        }
    }

    func printSummary() {
        // sort by most recent
        let sortedFlows = flows.values.sorted { $0.lastUpdated > $1.lastUpdated }
        // let sortedFlows = flows.values.sorted { $0.totalBytes > $1.totalBytes }
        var str = "\(appType)\n"
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
    var hostname: String?
    var rxBytes: Int = 0
    var txBytes: Int = 0
    var lastUpdated: Date = .init()
}
