//
//  Dep.swift
//  slowdown
//
//  Created by Sean Lee on 1/27/23.
//

import Foundation
import SwiftUI

// Load the registry
struct Consumer<T: ObservableObject>: ViewModifier {
    let type: T.Type
    let effect: (_ value: T) -> ()
    @Environment(\.registry) private var registry: Registry
    func body(content: Content) -> some View {
        return content.modifier(ConsumerInner(type: type, effect: effect, value: registry.resolve(type)))
    }
}

// Set up the Observed Object
struct ConsumerInner<T: ObservableObject>: ViewModifier {
    let type: T.Type
    let effect: (_ value: T) -> ()
    @ObservedObject var value: T
    func body(content: Content) -> some View {
        return content.onAppear {
            effect(value)
        }
    }
}

protocol Resolver {
    func resolve<T>(_ type: T.Type) -> T
}


class Registry: Resolver, ObservableObject {
    var services = [ServiceKey: Any]()
    
    var parent: Registry?
    
    init(parent: Registry? = nil) {
        self.parent = parent
    }
    
    init(deps: [any Dep], parent: Registry? = nil) {
        self.parent = parent
        self.bindDeps(deps: deps)
    }
    
    private func bindDeps(deps: [any Dep]) {
        for dep in deps.reversed() {
            self.bind(key: dep.getServiceKey(),  service: dep.create(r: self))
        }
    }
    
    func bind(key: ServiceKey, service: Any) {
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
    let deps: [any Dep]
    @Environment(\.registry) private var parent: Registry
    
    func body(content: Content) -> some View {
        content.modifier(ProviderInner(deps: deps, parent: parent))
    }
}


private struct ProviderInner: ViewModifier {
    @StateObject private var registry: Registry
    let deps: [any Dep]
    
    init(deps: [any Dep], parent: Registry? = nil) {
        self._registry = StateObject(wrappedValue: Registry(deps: deps, parent: parent))
        self.deps = deps
    }
    
    func body(content: Content) -> some View {
        content.modifier(ProviderViewer(deps: deps, registry: registry))
            .environment(\.registry, registry)
    }
}

extension View {
    func provideDeps(_ deps: [any Dep]) -> some View {
        self.modifier(Provider(deps: deps))
    }
    
    func consumeDep<T: ObservableObject>(_ type: T.Type, effect: @escaping (T) -> ()) -> some View {
        self.modifier(Consumer(type: type, effect: effect))
    }
}

private struct RegistryKey: EnvironmentKey {
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

protocol Dep {
    associatedtype T: ObservableObject
    func create(r: Registry) -> T
}

private extension Dep {
    func getServiceKey() -> ServiceKey {
        return ServiceKey(serviceType: T.self)
    }
    func environmentObject<Content: View>(registry: Registry, content: Content) -> some View {
        return content.environmentObject(registry.resolve(T.self))
    }
}
