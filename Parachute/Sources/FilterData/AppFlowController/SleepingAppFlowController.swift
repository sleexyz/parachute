
import NetworkExtension
import FilterCommon
import OSLog

class SleepingAppFlowController: AppFlowController {
    let app: App
    let logger: Logger

    public init (app: App) {
        self.app = app
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DroppingAppFlowController.\(app.id)")
    }

    func handleInboundData(from flow: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict{
        // if offset < app.peekBytes {
        //     return NEFilterDataVerdict(passBytes: readBytes.count, peekBytes: app.peekBytes)
        // }
        usleep(app.sleepTime)
        return NEFilterDataVerdict(passBytes: readBytes.count, peekBytes: app.peekBytes)
    }
}
