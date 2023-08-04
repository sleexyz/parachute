//
//  ServiceKey.swift
//  slowdown
//
//  Created by Sean Lee on 1/28/23.
//

import Foundation
import SwiftUI

internal struct RegistryKey: EnvironmentKey {
    static let defaultValue = Registry()
}

extension EnvironmentValues {
    var registry: Registry {
        get { self[RegistryKey.self] }
        set { self[RegistryKey.self] = newValue }
    }
}

struct ServiceKey {
  let serviceType: Any.Type
}

extension ServiceKey: Hashable {
    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(serviceType).hash(into: &hasher)
    }
}

func == (lhs: ServiceKey, rhs: ServiceKey) -> Bool {
    return lhs.serviceType == rhs.serviceType
}
