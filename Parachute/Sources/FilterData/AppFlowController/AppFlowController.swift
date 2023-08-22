import NetworkExtension

protocol AppFlowController {
    func handleInboundData(from flow: NEFilterFlow, offset: Int, readBytes: Data) -> NEFilterDataVerdict    
}