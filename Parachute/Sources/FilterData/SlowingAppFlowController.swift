import FilterCommon
import NetworkExtension
import OSLog

let SAMPLE_FREQUENCY = 1.0

// A proportional controller that throttles the download speed of a flow.
public class SlowingAppFlowController {
    // Parameters
    var app: App

    // var gain = 1 / 1e6 // microsecond
    var gain: Double = 1e-5

    var logger: Logger

    public required init(app: App) {
        self.app = app
        logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppFlowController.\(app.appType)")
        let startingLatencyPerByte = (20000 / app.targetRxSpeed(.shared)) * 4e-2 / Double(app.peekBytes) // 40ms per peek. Sweet spot computed experimentally.
        latencyPerByte = startingLatencyPerByte
    }

    var lastCleared: Date = .init()

    // Gets updated every handleInboundData call.
    private var lastSampleTime: Date = .init()
    private var rxBytes: Int = 0 // bytes received since last sample

    // Gets updated every sample.
    private var latencyPerByte: Double

    // Samples if ready, and update latencyPerByte
    func sampleIfReady(_ flow: NEFilterFlow, _ readBytes: Data) {
        let dt = Date().timeIntervalSince(lastSampleTime)
        if dt > SAMPLE_FREQUENCY {
            sample(flow, readBytes)
        }
    }

    func sample(_: NEFilterFlow, _: Data) {
        let now = Date()
        let dt = now.timeIntervalSince(lastSampleTime)

        latencyPerByte = getUpdatedLatencyPerByte(dt: dt)
        // logger.info("latencyPerByte: \(self.latencyPerByte)s")
        // Reset sample data
        rxBytes = 0
        lastSampleTime = now
    }

    func getUpdatedLatencyPerByte(dt: TimeInterval) -> Double {
        let rxSpeed = Double(rxBytes) / dt

        if rxSpeed.isInfinite || rxSpeed.isNaN {
            return 0
        }

        // Proportional error
        // Positive error means rxSpeed > targetRxSpeed, which means we're too fast
        // So we need to increase latencyPerByte.
        // Negative error means rxSpeed < targetRxSpeed, which means we're too slow
        // So we need to decrease latencyPerByte.
        let inputError = (app.targetRxSpeed(.shared) - rxSpeed) / app.targetRxSpeed(.shared)
        let update = -1 * inputError * gain

        var newLatencyPerByte = latencyPerByte + update
        if newLatencyPerByte <= 0 {
            newLatencyPerByte = 0
        } else {
            // logger.info("rxSpeed: \(rxSpeed) input error proportion: \(inputError), update: \(update), updateProportion: \(update / self.latencyPerByte), targetLatency: \(newLatencyPerByte)")
        }
        return newLatencyPerByte
    }

    public func handleInboundData(from flow: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict {
        rxBytes += readBytes.count
        sampleIfReady(flow, readBytes)
        let verdict = getVerdict(from: flow, offset: offset, readBytes: readBytes)
        return verdict
    }

    private func getVerdict(from _: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict {
        if offset < app.preSlowingBytes(.shared) {
            return NEFilterDataVerdict(passBytes: readBytes.count, peekBytes: app.preSlowingBytes(.shared))
        }
        let targetLatency = latencyPerByte * Double(readBytes.count)
        // logger.info("target latency: \(UInt32(targetLatency * 1e6)) microseconds")
        usleep(UInt32(targetLatency * 1e6))
        return NEFilterDataVerdict(passBytes: readBytes.count, peekBytes: app.peekBytes)
    }
}
