import protocol SwiftProtobuf.Message
import Foundation

public protocol CodableMessage: SwiftProtobuf.Message, Codable, Decodable, Hashable { }

extension CodableMessage {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        self = try Self(serializedData: data)
    }

    public func encode(to encoder: Encoder) throws {
        let data = try self.serializedData()
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
}
