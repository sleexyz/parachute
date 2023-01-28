//
//  Dep.swift
//  slowdown
//
//  Created by Sean Lee on 1/27/23.
//

import Foundation
import SwiftUI

struct Consumer<T: ObservableObject>: ViewModifier {
    let type: T.Type
    @EnvironmentObject private var obj: T
    let effect: (_ value: T) -> ()
    func body(content: Content) -> some View {
        return content.onAppear {
            effect(obj)
        }
    }
}

class Registry: ObservableObject, Resolver {
    var services = [ServiceKey: Any]()
    
    var parent: Registry?
    
    init(parent: Registry?) {
        self.parent = parent
    }
    
    func bind(service: Any) {
        let key = ServiceKey(serviceType: type(of:service))
        services[key] = service
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = ServiceKey(serviceType: type)
        if let value = services[key] {
            if case let value as T = value {
                return value
            }
            fatalError("error coercing Any to \(type)")
        }
        if let parent = parent {
            return parent.resolve(type)
        }
        fatalError("\(type) does not exist")
    }
}

protocol Resolver {
    func resolve<T>(_ type: T.Type) -> T
}

internal struct ProviderViewer: ViewModifier {
    let deps: [any Dep]
    let registry: Registry
    
    func body (content: Content) -> some View {
        if deps.isEmpty {
            return AnyView(content)
        }
        return AnyView(AnyView(deps[0].environmentObject(registry: registry, content: content))
            .modifier(ProviderViewer(deps: Array(deps.dropFirst(1)), registry: registry)))
    }
}

struct Provider: ViewModifier {
    @EnvironmentObject var parent: Registry
    let deps: [any Dep]
    
    func body(content: Content) -> some View {
        content.modifier(RootProvider(deps: deps, parent: parent))
    }
}

//private struct RegistryKey: EnvironmentKey {
//    static let defaultValue = Registry()
//}

struct RootProvider: ViewModifier {
    @StateObject private var registry: Registry
    @State var bound = false
    let deps: [any Dep]
    
    init(deps: [any Dep], parent: Registry? = nil) {
        self._registry = StateObject(wrappedValue: Registry(parent: parent))
        self.deps = deps
    }
    
    func body(content: Content) -> some View {
        Group {
            if !bound {
                Rectangle().hidden()
            } else {
                AnyView(content.modifier(ProviderViewer(deps: deps, registry: registry)))
            }
        }
        .environmentObject(registry)
        .onAppear {
            for dep in deps.reversed() {
                registry.bind(service: dep.create(resolver: registry))
            }
            bound = true
        }
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

protocol Dep {
    associatedtype T: ObservableObject
    func create(resolver: Resolver) -> T
}

extension Dep {
    func getType() -> T.Type {
        T.self
    }
    func resolve(registry: Registry) -> T {
        return registry.resolve(T.self)
    }
    
    func environmentObject<Content: View>(registry: Registry, content: Content) -> some View {
        return content.environmentObject(registry.resolve(T.self))
    }
}
