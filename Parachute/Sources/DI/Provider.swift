//
//  Provider.swift
//  slowdown
//
//  Created by Sean Lee on 1/28/23.
//

import Foundation
import SwiftUI

// A Simpler implementation of a Provider
struct SimpleProvider: ViewModifier {
    let dep: any Dep
    @Environment(\.registry) private var parent: Registry
    func body(content: Content) -> some View {
        content.modifier(SimpleProviderInner(dep: dep, parent: parent))
    }

    private struct SimpleProviderInner: ViewModifier {
        let dep: any Dep
        @StateObject private var registry: RegistryImpl

        init(dep: any Dep, parent: Registry) {
            _registry = StateObject(wrappedValue: RegistryImpl(deps: [dep], parent: parent))
            self.dep = dep
        }

        func body(content: Content) -> some View {
            AnyView(dep._environmentObject(registry: registry, content: content))
                .environment(\.registry, registry)
        }
    }
}

// A Provider provides
// 1) services to views -- via EnvironmentObject
// 2) services to other provider-created services -- via a view-hierarchy bound Registry
struct Provider: ViewModifier {
    let deps: [any Dep]
    @Environment(\.registry) private var parent: Registry

    func body(content: Content) -> some View {
        content.modifier(ProviderInner(deps: deps, parent: parent))
    }
}

// We separate ProviderInner to allow instantiation of the dep immediately after the registry is fetched.
private struct ProviderInner: ViewModifier {
    @StateObject private var registry: RegistryImpl
    let deps: [any Dep]

    init(deps: [any Dep], parent: Registry) {
        _registry = StateObject(wrappedValue: RegistryImpl(deps: deps, parent: parent))
        self.deps = deps
    }

    func body(content: Content) -> some View {
        content
            .modifier(ProviderViewer(deps: deps, registry: registry))
            .environment(\.registry, registry)
    }
}

internal struct ProviderViewer: ViewModifier {
    let deps: [any Dep]
    let registry: Registry

    func body(content: Content) -> some View {
        if deps.isEmpty {
            return AnyView(content)
        }
        return AnyView(AnyView(deps[0]._environmentObject(registry: registry, content: content))
            .modifier(ProviderViewer(deps: Array(deps.dropFirst(1)), registry: registry)))
    }
}
