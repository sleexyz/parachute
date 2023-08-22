import NetworkExtension
import OSLog
import FilterCommon

let SAMPLE_FREQUENCY = 1.0 // Every second

struct SampleVars {
    var latencyPerByte: Double
    var rxSpeed: Double
    var error: Double
    var update: Double

    func log(logger: Logger) {
        logger.info("target latency per Byte: \(latencyPerByte * 1e3) ms, rxSpeed: \(rxSpeed), error: \(error * 100)%, update: \(update)")
    }
}

// A proportional controller that throttles the download speed of a flow.
public class AppFlowController {
    // State
    lazy var flowDelayRegistry = FlowDelayRegistry(app: app)

    // Parameters
    var app: App

    // var gain = 1 / 1e6 // microsecond
    var gain: Double = 1000

    
    var logger: Logger
    
    public init (app: App) {
        self.app = app
        logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppFlowController.\(app.id)")
    }

    var lastCleared: Date = Date()

    // Gets updated every handleInboundData call.
    private var lastSampleTime: Date = Date()
    private var rxBytes: Int = 0 // bytes received since last sample

    // Gets updated every sample.
    private var latencyPerByte: Double = 18.0 * 1.0e3 * 4.0e5 / 40_000.0 / 1.0e9

    func rxSpeed(dt: TimeInterval) -> Double {
        return Double(rxBytes) / dt
    }


    // Samples if ready, and update latencyPerByte
    func sampleIfReady() {
        let dt = Date().timeIntervalSince(lastSampleTime)
        if dt > SAMPLE_FREQUENCY {
            sample()
        }
    }

    func sample() {
        let now = Date()
        var dt = now.timeIntervalSince(lastSampleTime)

        // Clamp dt to 2x SAMPLE_FREQUENCY
        if dt > 2 * SAMPLE_FREQUENCY {
            logger.info("Clamping dt to \(2*SAMPLE_FREQUENCY, privacy: .public), got \(dt, privacy: .public)")
            dt = 2 * SAMPLE_FREQUENCY
        }

        let sampleVars = updatedLatencyPerPeek(dt: dt)
        sampleVars.log(logger: logger)
        latencyPerByte = sampleVars.latencyPerByte

        // Reset sample data
        rxBytes = 0
        lastSampleTime = now
    }

    func updatedLatencyPerPeek(dt: TimeInterval) -> SampleVars {
        let rxSpeed = rxSpeed(dt: dt)

        // if rxSpeed == 0 {
        //     return 0
        // }

        // proportional error
        let error = (app.targetRxSpeed - rxSpeed) / app.targetRxSpeed
        let update = -1 * error * gain

        var newLatencyPerByte = latencyPerByte + update
        if newLatencyPerByte < 0 {
            newLatencyPerByte = 0
        }
        newLatencyPerByte = max(newLatencyPerByte, 0.00018 / 8)
        return SampleVars(latencyPerByte: newLatencyPerByte, rxSpeed: rxSpeed, error: error, update: update)    
    }

    public func handleInboundData(from flow: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict {
        sampleIfReady()
        let verdict = getVerdict(from: flow, offset: offset, readBytes: readBytes)
        if verdict.passBytesIsZero(){
            logger.info("Delaying flow \(flow.identifier, privacy: .public)")
            rxBytes += readBytes.count
        }
        return verdict
    }

    private func getVerdict(from flow: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict {
        if offset < app.peekBytes {
            logger.info("allowing initial PEEK_BYTES through for flow \(flow.identifier, privacy: .public)")
            return .allowPeekBytes(passBytes: readBytes.count, app: app)
        }

        guard flowDelayRegistry.hasFlow(flow: flow.identifier) else {
            guard flowDelayRegistry.canRegister() else {
                // Existing flow exists, delay.
                return .needRulesBlocking()
            }

            // Register new flow, delay.

            let targetLatency = latencyPerByte * Double(readBytes.count)
            let now = Date()
            let readyTime = now.addingTimeInterval(targetLatency)

            flowDelayRegistry.register(flow: flow.identifier, startTime: now, readyTime: readyTime)

            return .needRulesBlocking()
        }

        // Either delay because not ready or allow PEEK_BYTES:
        return flowDelayRegistry.getVerdict(
            flow: flow.identifier,
            allowVerdict: .allowPeekBytes( passBytes: readBytes.count, app: app)
        )
    }
}


struct FlowDelayEntry {
    var flow: UUID
    var startTime: Date
    var readyTime: Date
    var timesSentToFCP: Int = 0
    
    var delta: TimeInterval {
        readyTime.timeIntervalSince(startTime)
    }
    
    func increment() -> FlowDelayEntry {
        return FlowDelayEntry(flow: flow, startTime: startTime, readyTime: readyTime, timesSentToFCP: timesSentToFCP + 1)
    }
}

// Only allows one flow at a time.
public class SingularFlowDelayRegistry {
    var logger: Logger
    public init(appId: AppId) {
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppFlowController.\(appId)")
    }

    private var entry: FlowDelayEntry?

    public func hasFlow(flow: UUID) -> Bool {
        guard let entry = entry else {
            return false
        }
        return entry.flow == flow
    }

    public func canRegister() -> Bool {
        return entry == nil
    }

    public func register(flow: UUID, startTime: Date, readyTime: Date) {
        guard self.entry == nil else {
            logger.error("Flow \(flow, privacy: .public) tried to register, but there is already a flow registered: \(self.entry.debugDescription, privacy: .public)")
            return
        }
        self.entry = FlowDelayEntry(flow: flow, startTime: startTime, readyTime: readyTime)
    }

    public func getVerdict(flow: UUID, allowVerdict: NEFilterDataVerdict) -> NEFilterDataVerdict {
        // return .drop()
        guard let entry = entry else {
            return .needRulesBlocking()
        }
        // If flow is different, then we delay
        guard entry.flow == flow else {
            return .needRulesBlocking()
        }

        let error = Date().timeIntervalSince(entry.readyTime)
        if error > 0 {
            self.entry = nil
            let errorPercent = entry.delta > 0 ? "\(Int(error / entry.delta))%" : "ERROR"
            logger.info("Flow \(flow, privacy: .public) ready, with time error of \(errorPercent, privacy: .public) of \(entry.delta, privacy: .public), went through FCP \(entry.timesSentToFCP, privacy: .public) times")

            return allowVerdict
        }

        self.entry = entry.increment()
        logger.info("sending to FCP, iteration \(self.entry?.timesSentToFCP ?? -1, privacy: .public) ")
        return .needRulesBlocking()
    }
}


// Okay .pause() is not available but we can hack around it with filter control provider
// Wait a fixed time, and modulate peek bytes. lmfao.
public class FlowDelayRegistry {
    var logger: Logger

    public init(app: App) {
        self.logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppFlowController.\(app.id)")
    }

    public func canRegister() -> Bool {
        return true
    }

    private var flowDelays: [UUID: FlowDelayEntry] = [:]

    public func register(flow: UUID, startTime: Date, readyTime: Date) {
        flowDelays[flow] = FlowDelayEntry(flow: flow, startTime: startTime, readyTime: readyTime)
    }

    public func hasFlow(flow: UUID) -> Bool {
        return flowDelays[flow] != nil
    }

    public func getVerdict(flow: UUID, allowVerdict: NEFilterDataVerdict) -> NEFilterDataVerdict {
        guard let entry = flowDelays[flow] else {
            // Invariant error
            return .needRulesBlocking()
        }

        let error = Date().timeIntervalSince(entry.readyTime)
        if error > 0 {
            flowDelays.removeValue(forKey: flow)
            let errorPercent = entry.delta > 0 ? "\(Int(error / entry.delta))%" : "ERROR"
            logger.info("Flow \(flow, privacy: .public) ready, with time error of \(errorPercent, privacy: .public) of \(entry.delta, privacy: .public), went through FCP \(entry.timesSentToFCP, privacy: .public) times")
            return allowVerdict
        } else {
            flowDelays[flow] = entry.increment()
            return .needRulesBlocking()
        }
    }

    public func clearExpired() -> Int {
        let numFlows = flowDelays.count
        flowDelays = flowDelays.filter { $0.value.readyTime > Date() }
        if flowDelays.count != numFlows {
            return numFlows - flowDelays.count
        }
        return 0
    }
}
