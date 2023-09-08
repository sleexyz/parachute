//
//  Consumer.swift
//  slowdown
//
//  Created by Sean Lee on 1/28/23.
//

import Foundation
import SwiftUI

struct Consumer<T: ObservableObject>: ViewModifier {
    let type: T.Type
    let effect: (_ value: T) -> Void
    @EnvironmentObject private var obj: T
    func body(content: Content) -> some View {
        return content.onAppear {
            effect(obj)
        }
    }
}

// An alternative (unused) implementation that does not use @EnvironmentObject:

// Load the registry
private struct RegistryConsumer<T: ObservableObject>: ViewModifier {
    let type: T.Type
    let effect: (_ value: T) -> Void
    @Environment(\.registry) private var registry: Registry
    func body(content: Content) -> some View {
        return content.modifier(RegistryConsumerInner(type: type, effect: effect, value: registry.resolve(type)))
    }
}

// Set up the Observed Object
private struct RegistryConsumerInner<T: ObservableObject>: ViewModifier {
    let type: T.Type
    let effect: (_ value: T) -> Void
    @ObservedObject var value: T
    func body(content: Content) -> some View {
        return content.onAppear {
            effect(value)
        }
    }
}
