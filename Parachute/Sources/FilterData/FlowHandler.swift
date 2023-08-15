import NetworkExtension
import Logging
import LoggingOSLog

public class FlowHandler {
    let logger: Logger = {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        return Logger(label: "industries.strange.slowdown.FlowHandler")
    }()

    public init() {
        logger.info("FlowHandler init")
    }

    public func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        logger.info("New flow: \(flow)")
        if flow.sourceAppIdentifier?.hasSuffix(".com.zhiliaoapp.musically") ?? false {
            return .drop()
        }
        if flow.sourceAppIdentifier?.hasSuffix(".com.burbn.instagram") ?? false {
            return .drop()
        }
        if flow.sourceAppIdentifier?.hasSuffix(".com.atebits.Tweetie2") ?? false {
            return .drop()
        }
        
        return .allow()
    }
}
