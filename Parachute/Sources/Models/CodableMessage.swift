import Foundation
import protocol SwiftProtobuf.Message

public protocol CodableMessage: SwiftProtobuf.Message, Codable, Decodable, Hashable {}

public extension CodableMessage {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        self = try Self(serializedData: data)
    }

    func encode(to encoder: Encoder) throws {
        let data = try serializedData()
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
}
