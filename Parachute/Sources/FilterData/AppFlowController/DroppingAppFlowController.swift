
import NetworkExtension
import FilterCommon
import OSLog

class DroppingAppFlowController: AppFlowController {
    let app: App
    let logger: Logger

    public init (app: App) {
        self.app = app
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DroppingAppFlowController.\(app.id)")
    }

    func handleInboundData(from flow: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict{
        if (offset < app.preSlowingBytes) {
            return NEFilterDataVerdict(passBytes: readBytes.count, peekBytes: app.preSlowingBytes)
        }
        return .needRulesBlocking()
    }
}
