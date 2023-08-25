import NetworkExtension

public protocol FlowController {
    func handleInboundData(from flow: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict    
}


