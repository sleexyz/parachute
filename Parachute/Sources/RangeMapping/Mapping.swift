import Foundation

public enum Warp {
    case linear
    case exponential
}

public struct Mapping {
    public let a: Double
    public let b: Double
    public let c: Double
    public let d: Double
    public var inWarp: Warp = .linear
    public var outWarp: Warp = .linear
    public var clip: Bool = false

    public init(a: Double, b: Double, c: Double, d: Double, inWarp: Warp = .linear, outWarp: Warp = .linear, clip: Bool = false) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.inWarp = inWarp
        self.outWarp = outWarp
        self.clip = clip
    }
    
    public func map(_ x: Double) -> Double {
        var y = x
        // 1) normalize
        switch inWarp {
        case .linear:
            y = (y - a) / (b - a)
        case .exponential:
            y = (log(y) - log(a)) / (log(b) - log(a))
        }
        
        // 2) scale
        switch outWarp {
        case .linear:
            y = d * y + c * (1 - y)
        case .exponential:
            y = pow(d, y) * pow(c, 1 - y)
        }
        if clip {
            let lowerBound = min(c, d)
            let upperBound = max(c, d)
            y = max(min(y, upperBound), lowerBound)
        }
        return y
    }
    
    public var inverse: Mapping {
        if clip {
            fatalError("cannot invert clipped mapping")
        }
        return Mapping(a: c, b: d, c: a, d: b, inWarp: outWarp, outWarp: inWarp)
    }
}

public extension Double {
    func applyMapping(_ mapping: Mapping) -> Double {
        return mapping.map(self)
    }
}

public extension FloatingPoint {
  @inlinable
  func signum( ) -> Self {
    if self < 0 { return -1 }
    if self > 0 { return 1 }
    return 0
  }
}
