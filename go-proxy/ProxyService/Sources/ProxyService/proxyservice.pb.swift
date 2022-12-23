// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: proxyservice.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct Proxyservice_Settings {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var baseRxSpeedTarget: Double = 0

  public var useExponentialDecay: Bool = false

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_Request {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var message: Proxyservice_Request.OneOf_Message? = nil

  public var setSettings: Proxyservice_Settings {
    get {
      if case .setSettings(let v)? = message {return v}
      return Proxyservice_Settings()
    }
    set {message = .setSettings(newValue)}
  }

  public var setTemporaryRxSpeedTarget: Proxyservice_SetTemporaryRxSpeedTargetRequest {
    get {
      if case .setTemporaryRxSpeedTarget(let v)? = message {return v}
      return Proxyservice_SetTemporaryRxSpeedTargetRequest()
    }
    set {message = .setTemporaryRxSpeedTarget(newValue)}
  }

  public var resetState: Proxyservice_ResetStateRequest {
    get {
      if case .resetState(let v)? = message {return v}
      return Proxyservice_ResetStateRequest()
    }
    set {message = .resetState(newValue)}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum OneOf_Message: Equatable {
    case setSettings(Proxyservice_Settings)
    case setTemporaryRxSpeedTarget(Proxyservice_SetTemporaryRxSpeedTargetRequest)
    case resetState(Proxyservice_ResetStateRequest)

  #if !swift(>=4.1)
    public static func ==(lhs: Proxyservice_Request.OneOf_Message, rhs: Proxyservice_Request.OneOf_Message) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.setSettings, .setSettings): return {
        guard case .setSettings(let l) = lhs, case .setSettings(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.setTemporaryRxSpeedTarget, .setTemporaryRxSpeedTarget): return {
        guard case .setTemporaryRxSpeedTarget(let l) = lhs, case .setTemporaryRxSpeedTarget(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.resetState, .resetState): return {
        guard case .resetState(let l) = lhs, case .resetState(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public init() {}
}

public struct Proxyservice_ResetStateRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_SetTemporaryRxSpeedTargetRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var speed: Double = 0

  public var duration: Int32 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_ServerState {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var apps: [Proxyservice_AppState] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_AppState {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var points: Double = 0

  public var name: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_Sample {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var ip: String = String()

  public var rxBytes: Int64 = 0

  public var startTime: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _startTime ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_startTime = newValue}
  }
  /// Returns true if `startTime` has been explicitly set.
  public var hasStartTime: Bool {return self._startTime != nil}
  /// Clears the value of `startTime`. Subsequent reads from it will return its default value.
  public mutating func clearStartTime() {self._startTime = nil}

  /// how long the sample
  public var duration: Int64 = 0

  public var rxSpeed: Double = 0

  public var rxSpeedTarget: Double = 0

  public var appMatch: String = String()

  public var slowReason: String = String()

  public var dnsMatchers: [String] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _startTime: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Proxyservice_Settings: @unchecked Sendable {}
extension Proxyservice_Request: @unchecked Sendable {}
extension Proxyservice_Request.OneOf_Message: @unchecked Sendable {}
extension Proxyservice_ResetStateRequest: @unchecked Sendable {}
extension Proxyservice_SetTemporaryRxSpeedTargetRequest: @unchecked Sendable {}
extension Proxyservice_ServerState: @unchecked Sendable {}
extension Proxyservice_AppState: @unchecked Sendable {}
extension Proxyservice_Sample: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proxyservice"

extension Proxyservice_Settings: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Settings"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "baseRxSpeedTarget"),
    2: .same(proto: "useExponentialDecay"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularDoubleField(value: &self.baseRxSpeedTarget) }()
      case 2: try { try decoder.decodeSingularBoolField(value: &self.useExponentialDecay) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.baseRxSpeedTarget != 0 {
      try visitor.visitSingularDoubleField(value: self.baseRxSpeedTarget, fieldNumber: 1)
    }
    if self.useExponentialDecay != false {
      try visitor.visitSingularBoolField(value: self.useExponentialDecay, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_Settings, rhs: Proxyservice_Settings) -> Bool {
    if lhs.baseRxSpeedTarget != rhs.baseRxSpeedTarget {return false}
    if lhs.useExponentialDecay != rhs.useExponentialDecay {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_Request: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Request"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "setSettings"),
    2: .same(proto: "setTemporaryRxSpeedTarget"),
    3: .same(proto: "resetState"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try {
        var v: Proxyservice_Settings?
        var hadOneofValue = false
        if let current = self.message {
          hadOneofValue = true
          if case .setSettings(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.message = .setSettings(v)
        }
      }()
      case 2: try {
        var v: Proxyservice_SetTemporaryRxSpeedTargetRequest?
        var hadOneofValue = false
        if let current = self.message {
          hadOneofValue = true
          if case .setTemporaryRxSpeedTarget(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.message = .setTemporaryRxSpeedTarget(v)
        }
      }()
      case 3: try {
        var v: Proxyservice_ResetStateRequest?
        var hadOneofValue = false
        if let current = self.message {
          hadOneofValue = true
          if case .resetState(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.message = .resetState(v)
        }
      }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    switch self.message {
    case .setSettings?: try {
      guard case .setSettings(let v)? = self.message else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }()
    case .setTemporaryRxSpeedTarget?: try {
      guard case .setTemporaryRxSpeedTarget(let v)? = self.message else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }()
    case .resetState?: try {
      guard case .resetState(let v)? = self.message else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_Request, rhs: Proxyservice_Request) -> Bool {
    if lhs.message != rhs.message {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_ResetStateRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ResetStateRequest"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_ResetStateRequest, rhs: Proxyservice_ResetStateRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_SetTemporaryRxSpeedTargetRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".SetTemporaryRxSpeedTargetRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "speed"),
    2: .same(proto: "duration"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularDoubleField(value: &self.speed) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.duration) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.speed != 0 {
      try visitor.visitSingularDoubleField(value: self.speed, fieldNumber: 1)
    }
    if self.duration != 0 {
      try visitor.visitSingularInt32Field(value: self.duration, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_SetTemporaryRxSpeedTargetRequest, rhs: Proxyservice_SetTemporaryRxSpeedTargetRequest) -> Bool {
    if lhs.speed != rhs.speed {return false}
    if lhs.duration != rhs.duration {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_ServerState: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ServerState"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "apps"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.apps) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.apps.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.apps, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_ServerState, rhs: Proxyservice_ServerState) -> Bool {
    if lhs.apps != rhs.apps {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_AppState: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".AppState"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "points"),
    2: .same(proto: "name"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularDoubleField(value: &self.points) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.name) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.points != 0 {
      try visitor.visitSingularDoubleField(value: self.points, fieldNumber: 1)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_AppState, rhs: Proxyservice_AppState) -> Bool {
    if lhs.points != rhs.points {return false}
    if lhs.name != rhs.name {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_Sample: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Sample"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "ip"),
    2: .same(proto: "rxBytes"),
    3: .same(proto: "startTime"),
    4: .same(proto: "duration"),
    5: .same(proto: "rxSpeed"),
    6: .same(proto: "rxSpeedTarget"),
    7: .same(proto: "appMatch"),
    8: .same(proto: "slowReason"),
    9: .same(proto: "dnsMatchers"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.ip) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.rxBytes) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._startTime) }()
      case 4: try { try decoder.decodeSingularInt64Field(value: &self.duration) }()
      case 5: try { try decoder.decodeSingularDoubleField(value: &self.rxSpeed) }()
      case 6: try { try decoder.decodeSingularDoubleField(value: &self.rxSpeedTarget) }()
      case 7: try { try decoder.decodeSingularStringField(value: &self.appMatch) }()
      case 8: try { try decoder.decodeSingularStringField(value: &self.slowReason) }()
      case 9: try { try decoder.decodeRepeatedStringField(value: &self.dnsMatchers) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.ip.isEmpty {
      try visitor.visitSingularStringField(value: self.ip, fieldNumber: 1)
    }
    if self.rxBytes != 0 {
      try visitor.visitSingularInt64Field(value: self.rxBytes, fieldNumber: 2)
    }
    try { if let v = self._startTime {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    if self.duration != 0 {
      try visitor.visitSingularInt64Field(value: self.duration, fieldNumber: 4)
    }
    if self.rxSpeed != 0 {
      try visitor.visitSingularDoubleField(value: self.rxSpeed, fieldNumber: 5)
    }
    if self.rxSpeedTarget != 0 {
      try visitor.visitSingularDoubleField(value: self.rxSpeedTarget, fieldNumber: 6)
    }
    if !self.appMatch.isEmpty {
      try visitor.visitSingularStringField(value: self.appMatch, fieldNumber: 7)
    }
    if !self.slowReason.isEmpty {
      try visitor.visitSingularStringField(value: self.slowReason, fieldNumber: 8)
    }
    if !self.dnsMatchers.isEmpty {
      try visitor.visitRepeatedStringField(value: self.dnsMatchers, fieldNumber: 9)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_Sample, rhs: Proxyservice_Sample) -> Bool {
    if lhs.ip != rhs.ip {return false}
    if lhs.rxBytes != rhs.rxBytes {return false}
    if lhs._startTime != rhs._startTime {return false}
    if lhs.duration != rhs.duration {return false}
    if lhs.rxSpeed != rhs.rxSpeed {return false}
    if lhs.rxSpeedTarget != rhs.rxSpeedTarget {return false}
    if lhs.appMatch != rhs.appMatch {return false}
    if lhs.slowReason != rhs.slowReason {return false}
    if lhs.dnsMatchers != rhs.dnsMatchers {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
