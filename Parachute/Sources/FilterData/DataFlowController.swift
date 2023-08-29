import NetworkExtension
import SwiftProtobuf
import ProxyService
import OSLog
import FilterCommon
import Models

public class DataFlowController {
    let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DataFlowController")

    var settings: Proxyservice_Settings

    weak var provider: NEFilterDataProvider?

    var flowRegistry = FlowRegistry()
    // var instagram = SlowingAppFlowController(app: .instagram)
    // var tiktok =    SlowingAppFlowController(app: .tiktok)
    // var twitter =   SlowingAppFlowController(app: .twitter)
    // var youtube =   SlowingAppFlowController(app: .youtube)

    public init(settings: Proxyservice_Settings) {
        logger.info("DataFlowController init")
        self.settings = settings
    }

    public func updateSettings(settings: Proxyservice_Settings) {
        self.settings = settings
        logger.info("updated settings: \(settings.debugDescription, privacy: .public)")
    }

    public func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        guard let app = flow.matchSocialMedia() else {
            return .allow()
        }

        // NOTE: we intentionally don't check the app type here and allow here, 
        //      since .allow() will persist the entire flow and apps persist flows 
        //      for a long time.

        flowRegistry.register(flow: flow)

        // Pass to handleInboundData
        return .filterDataVerdict(withFilterInbound: true, peekInboundBytes: app.preSlowingBytes,  filterOutbound: false, peekOutboundBytes: 0)
    }

    public func handleInboundData(from flow: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict {
        guard let app: App = flow.matchSocialMedia() else {
            return .allow()
        }

        let allowPeek = NEFilterDataVerdict(passBytes: readBytes.count, peekBytes: 128 * 1024 * 1024)

        guard settings.isAppEnabled(app: app.appType) else {
            // #if DEBUG
            // logger.info("App disabled: \(app.appType.rawValue)")
            // #endif
            return allowPeek
        }

        // TODO: pause sampling as well
        if settings.isInScrollSession {
            return allowPeek
        }

        return flowRegistry.getFlowController(for: flow).handleInboundData(from: flow, offset: offset, readBytes: readBytes)
    }

    public func handleInboundDataComplete(for flow: NEFilterFlow) -> NEFilterDataVerdict {
        // Deregister flow
        flowRegistry.deregister(for: flow)
        return .allow()
    }
}

public class FlowRegistry {
    public typealias AFC = SlowingAppFlowController

    var logger: Logger
    private var flowDelays: [UUID: AFC] = [:]

    public init() {
        logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "FlowRegistry")
    }



    public func register(flow: NEFilterFlow) {
        guard let app = flow.matchSocialMedia() else {
            // Invariant error. We should only be registering social media flows.
            return
        }
        flowDelays[flow.identifier] = AFC(app: app, allowPreSlowingBytes: true)
    }

    public func deregister(for flow: NEFilterFlow) {
        flowDelays.removeValue(forKey: flow.identifier)
    }

    public func getFlowController(for flow: NEFilterFlow) -> AFC {
        return flowDelays[flow.identifier]!
    }
}
