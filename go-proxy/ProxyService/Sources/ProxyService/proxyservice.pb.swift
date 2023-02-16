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

public enum Proxyservice_Mode: SwiftProtobuf.Enum {
  public typealias RawValue = Int
  case progressive // = 0
  case focus // = 1
  case UNRECOGNIZED(Int)

  public init() {
    self = .progressive
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .progressive
    case 1: self = .focus
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .progressive: return 0
    case .focus: return 1
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension Proxyservice_Mode: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [Proxyservice_Mode] = [
    .progressive,
    .focus,
  ]
}

#endif  // swift(>=4.2)

public struct Proxyservice_Settings {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// latest version: 1
  public var version: Int32 = 0

  public var baseRxSpeedTarget: Double = 0

  public var temporaryRxSpeedTarget: Double = 0

  public var temporaryRxSpeedExpiry: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _temporaryRxSpeedExpiry ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_temporaryRxSpeedExpiry = newValue}
  }
  /// Returns true if `temporaryRxSpeedExpiry` has been explicitly set.
  public var hasTemporaryRxSpeedExpiry: Bool {return self._temporaryRxSpeedExpiry != nil}
  /// Clears the value of `temporaryRxSpeedExpiry`. Subsequent reads from it will return its default value.
  public mutating func clearTemporaryRxSpeedExpiry() {self._temporaryRxSpeedExpiry = nil}

  /// HP per second
  public var usageHealRate: Double = 0

  public var usageMaxHp: Double = 0

  public var usageBaseRxSpeedTarget: Double = 0

  public var debug: Bool = false

  public var mode: Proxyservice_Mode = .progressive

  public var pauseExpiry: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _pauseExpiry ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_pauseExpiry = newValue}
  }
  /// Returns true if `pauseExpiry` has been explicitly set.
  public var hasPauseExpiry: Bool {return self._pauseExpiry != nil}
  /// Clears the value of `pauseExpiry`. Subsequent reads from it will return its default value.
  public mutating func clearPauseExpiry() {self._pauseExpiry = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _temporaryRxSpeedExpiry: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
  fileprivate var _pauseExpiry: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
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

  public var getState: Proxyservice_GetStateRequest {
    get {
      if case .getState(let v)? = message {return v}
      return Proxyservice_GetStateRequest()
    }
    set {message = .getState(newValue)}
  }

  public var heal: Proxyservice_HealRequest {
    get {
      if case .heal(let v)? = message {return v}
      return Proxyservice_HealRequest()
    }
    set {message = .heal(newValue)}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum OneOf_Message: Equatable {
    case setSettings(Proxyservice_Settings)
    case getState(Proxyservice_GetStateRequest)
    case heal(Proxyservice_HealRequest)

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
      case (.getState, .getState): return {
        guard case .getState(let l) = lhs, case .getState(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.heal, .heal): return {
        guard case .heal(let l) = lhs, case .heal(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public init() {}
}

public struct Proxyservice_UncaughtError {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var error: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_SetSettingsResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_GetStateRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_GetStateResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var usagePoints: Double = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_HealRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_HealResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var usagePoints: Double = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_ServerState {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var apps: [Proxyservice_AppState] = []

  public var usagePoints: Double = 0

  public var ratio: Double = 0

  public var progressiveRxSpeedTarget: Double = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Proxyservice_AppState {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var txPoints: Double = 0

  public var name: String = String()

  public var rxPoints: Double = 0

  public var txPointsMax: Double = 0

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
extension Proxyservice_Mode: @unchecked Sendable {}
extension Proxyservice_Settings: @unchecked Sendable {}
extension Proxyservice_Request: @unchecked Sendable {}
extension Proxyservice_Request.OneOf_Message: @unchecked Sendable {}
extension Proxyservice_UncaughtError: @unchecked Sendable {}
extension Proxyservice_SetSettingsResponse: @unchecked Sendable {}
extension Proxyservice_GetStateRequest: @unchecked Sendable {}
extension Proxyservice_GetStateResponse: @unchecked Sendable {}
extension Proxyservice_HealRequest: @unchecked Sendable {}
extension Proxyservice_HealResponse: @unchecked Sendable {}
extension Proxyservice_ServerState: @unchecked Sendable {}
extension Proxyservice_AppState: @unchecked Sendable {}
extension Proxyservice_Sample: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proxyservice"

extension Proxyservice_Mode: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "PROGRESSIVE"),
    1: .same(proto: "FOCUS"),
  ]
}

extension Proxyservice_Settings: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Settings"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    4: .same(proto: "version"),
    1: .same(proto: "baseRxSpeedTarget"),
    2: .same(proto: "temporaryRxSpeedTarget"),
    3: .same(proto: "temporaryRxSpeedExpiry"),
    5: .same(proto: "usageHealRate"),
    6: .same(proto: "usageMaxHP"),
    9: .same(proto: "usageBaseRxSpeedTarget"),
    7: .same(proto: "debug"),
    8: .same(proto: "mode"),
    10: .same(proto: "pauseExpiry"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularDoubleField(value: &self.baseRxSpeedTarget) }()
      case 2: try { try decoder.decodeSingularDoubleField(value: &self.temporaryRxSpeedTarget) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._temporaryRxSpeedExpiry) }()
      case 4: try { try decoder.decodeSingularInt32Field(value: &self.version) }()
      case 5: try { try decoder.decodeSingularDoubleField(value: &self.usageHealRate) }()
      case 6: try { try decoder.decodeSingularDoubleField(value: &self.usageMaxHp) }()
      case 7: try { try decoder.decodeSingularBoolField(value: &self.debug) }()
      case 8: try { try decoder.decodeSingularEnumField(value: &self.mode) }()
      case 9: try { try decoder.decodeSingularDoubleField(value: &self.usageBaseRxSpeedTarget) }()
      case 10: try { try decoder.decodeSingularMessageField(value: &self._pauseExpiry) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.baseRxSpeedTarget != 0 {
      try visitor.visitSingularDoubleField(value: self.baseRxSpeedTarget, fieldNumber: 1)
    }
    if self.temporaryRxSpeedTarget != 0 {
      try visitor.visitSingularDoubleField(value: self.temporaryRxSpeedTarget, fieldNumber: 2)
    }
    try { if let v = self._temporaryRxSpeedExpiry {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    if self.version != 0 {
      try visitor.visitSingularInt32Field(value: self.version, fieldNumber: 4)
    }
    if self.usageHealRate != 0 {
      try visitor.visitSingularDoubleField(value: self.usageHealRate, fieldNumber: 5)
    }
    if self.usageMaxHp != 0 {
      try visitor.visitSingularDoubleField(value: self.usageMaxHp, fieldNumber: 6)
    }
    if self.debug != false {
      try visitor.visitSingularBoolField(value: self.debug, fieldNumber: 7)
    }
    if self.mode != .progressive {
      try visitor.visitSingularEnumField(value: self.mode, fieldNumber: 8)
    }
    if self.usageBaseRxSpeedTarget != 0 {
      try visitor.visitSingularDoubleField(value: self.usageBaseRxSpeedTarget, fieldNumber: 9)
    }
    try { if let v = self._pauseExpiry {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 10)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_Settings, rhs: Proxyservice_Settings) -> Bool {
    if lhs.version != rhs.version {return false}
    if lhs.baseRxSpeedTarget != rhs.baseRxSpeedTarget {return false}
    if lhs.temporaryRxSpeedTarget != rhs.temporaryRxSpeedTarget {return false}
    if lhs._temporaryRxSpeedExpiry != rhs._temporaryRxSpeedExpiry {return false}
    if lhs.usageHealRate != rhs.usageHealRate {return false}
    if lhs.usageMaxHp != rhs.usageMaxHp {return false}
    if lhs.usageBaseRxSpeedTarget != rhs.usageBaseRxSpeedTarget {return false}
    if lhs.debug != rhs.debug {return false}
    if lhs.mode != rhs.mode {return false}
    if lhs._pauseExpiry != rhs._pauseExpiry {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_Request: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Request"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "setSettings"),
    2: .same(proto: "getState"),
    3: .same(proto: "heal"),
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
        var v: Proxyservice_GetStateRequest?
        var hadOneofValue = false
        if let current = self.message {
          hadOneofValue = true
          if case .getState(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.message = .getState(v)
        }
      }()
      case 3: try {
        var v: Proxyservice_HealRequest?
        var hadOneofValue = false
        if let current = self.message {
          hadOneofValue = true
          if case .heal(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.message = .heal(v)
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
    case .getState?: try {
      guard case .getState(let v)? = self.message else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }()
    case .heal?: try {
      guard case .heal(let v)? = self.message else { preconditionFailure() }
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

extension Proxyservice_UncaughtError: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".UncaughtError"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "error"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.error) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.error.isEmpty {
      try visitor.visitSingularStringField(value: self.error, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_UncaughtError, rhs: Proxyservice_UncaughtError) -> Bool {
    if lhs.error != rhs.error {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_SetSettingsResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".SetSettingsResponse"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_SetSettingsResponse, rhs: Proxyservice_SetSettingsResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_GetStateRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".GetStateRequest"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_GetStateRequest, rhs: Proxyservice_GetStateRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_GetStateResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".GetStateResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "usagePoints"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularDoubleField(value: &self.usagePoints) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.usagePoints != 0 {
      try visitor.visitSingularDoubleField(value: self.usagePoints, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_GetStateResponse, rhs: Proxyservice_GetStateResponse) -> Bool {
    if lhs.usagePoints != rhs.usagePoints {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_HealRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".HealRequest"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_HealRequest, rhs: Proxyservice_HealRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_HealResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".HealResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "usagePoints"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularDoubleField(value: &self.usagePoints) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.usagePoints != 0 {
      try visitor.visitSingularDoubleField(value: self.usagePoints, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_HealResponse, rhs: Proxyservice_HealResponse) -> Bool {
    if lhs.usagePoints != rhs.usagePoints {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_ServerState: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ServerState"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "apps"),
    2: .same(proto: "usagePoints"),
    3: .same(proto: "ratio"),
    4: .same(proto: "progressiveRxSpeedTarget"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.apps) }()
      case 2: try { try decoder.decodeSingularDoubleField(value: &self.usagePoints) }()
      case 3: try { try decoder.decodeSingularDoubleField(value: &self.ratio) }()
      case 4: try { try decoder.decodeSingularDoubleField(value: &self.progressiveRxSpeedTarget) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.apps.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.apps, fieldNumber: 1)
    }
    if self.usagePoints != 0 {
      try visitor.visitSingularDoubleField(value: self.usagePoints, fieldNumber: 2)
    }
    if self.ratio != 0 {
      try visitor.visitSingularDoubleField(value: self.ratio, fieldNumber: 3)
    }
    if self.progressiveRxSpeedTarget != 0 {
      try visitor.visitSingularDoubleField(value: self.progressiveRxSpeedTarget, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_ServerState, rhs: Proxyservice_ServerState) -> Bool {
    if lhs.apps != rhs.apps {return false}
    if lhs.usagePoints != rhs.usagePoints {return false}
    if lhs.ratio != rhs.ratio {return false}
    if lhs.progressiveRxSpeedTarget != rhs.progressiveRxSpeedTarget {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proxyservice_AppState: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".AppState"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "txPoints"),
    2: .same(proto: "name"),
    3: .same(proto: "rxPoints"),
    4: .same(proto: "txPointsMax"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularDoubleField(value: &self.txPoints) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 3: try { try decoder.decodeSingularDoubleField(value: &self.rxPoints) }()
      case 4: try { try decoder.decodeSingularDoubleField(value: &self.txPointsMax) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.txPoints != 0 {
      try visitor.visitSingularDoubleField(value: self.txPoints, fieldNumber: 1)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 2)
    }
    if self.rxPoints != 0 {
      try visitor.visitSingularDoubleField(value: self.rxPoints, fieldNumber: 3)
    }
    if self.txPointsMax != 0 {
      try visitor.visitSingularDoubleField(value: self.txPointsMax, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proxyservice_AppState, rhs: Proxyservice_AppState) -> Bool {
    if lhs.txPoints != rhs.txPoints {return false}
    if lhs.name != rhs.name {return false}
    if lhs.rxPoints != rhs.rxPoints {return false}
    if lhs.txPointsMax != rhs.txPointsMax {return false}
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
