import NetworkExtension
import Logging
import LoggingOSLog

public class DataFlowHandler {
    let logger: Logger = {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        return Logger(label: "industries.strange.slowdown.DataFlowHandler")
    }()

    public init() {
        logger.info("DataFlowHandler init")
    }

    public func matchSocialMedia(flow: NEFilterFlow) -> Bool {
        if flow.sourceAppIdentifier?.hasSuffix(".com.zhiliaoapp.musically") ?? false {
            return true
        }
        if flow.sourceAppIdentifier?.hasSuffix(".com.burbn.instagram") ?? false {
            return true
        }
        if flow.sourceAppIdentifier?.hasSuffix(".com.atebits.Tweetie2") ?? false {
            return true
        }
        return false

    }

    public func handleRulesChanged() {
        logger.info("Rules changed")
    }

    public func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterNewFlowVerdict {
        logger.info("New flow: \(flow)")

        if matchSocialMedia(flow: flow) {
            logger.info("Matched social media")
            return .needRules()
        }
        
        return .allow()
    }
}
