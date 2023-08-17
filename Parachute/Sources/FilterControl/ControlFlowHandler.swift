import NetworkExtension
import Logging
import LoggingOSLog

public class ControlFlowHandler {
    let logger: Logger = {
        LoggingSystem.bootstrap(LoggingOSLog.init)
        return Logger(label: "industries.strange.slowdown.ControlFlowHandler")
    }()

    public init() {
        logger.info("ControlFlowHandler init")
    }

    public func handleNewFlow(_ flow: NEFilterFlow) -> NEFilterControlVerdict {
        logger.info("New flow: \(flow)")
        return .allow(withUpdateRules: true)
        // return .drop(withUpdateRules: false)
    }
}
