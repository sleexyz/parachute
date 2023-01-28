//
//  Registry.swift
//  slowdown
//
//  Created by Sean Lee on 1/28/23.
//

import Foundation
import SwiftUI

class Registry: ObservableObject {
    func resolve<T>(_ type: T.Type) -> T {
        fatalError("\(type) does not exist")
    }
}

// A Registry contains an immutable collection of bound services.
// A Registry can contain a reference to a parent registry to use for resolution.
class RegistryImpl: Registry {
    private var services = [ServiceKey: Any]()
    private var parent: Registry
    
    init(deps: [any Dep], parent: Registry) {
        self.parent = parent
        super.init()
        self.bindDeps(deps: deps)
    }
    
    private func bindDeps(deps: [any Dep]) {
        for dep in deps.reversed() {
            let service = dep.create(r: self)
            for key in dep.getServiceKeys() {
                self.bind(key: key, service: service)
            }
        }
    }
    
    private func bind(key: ServiceKey, service: Any) {
        services[key] = service
    }
    
    override func resolve<T>(_ type: T.Type) -> T {
        let key = ServiceKey(serviceType: type)
        if let value = services[key] {
            if case let value as T = value {
                return value
            }
            fatalError("error coercing Any to \(type)")
        }
        return parent.resolve(type)
    }
}
