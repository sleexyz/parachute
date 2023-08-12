//
//  ScrollSessionViewController.swift
//  slowdown
//
//  Created by Sean Lee on 8/11/23.
//

import Foundation
import DI
import Logging

public class ScrollSessionViewController: ObservableObject  {
    public static var shared: ScrollSessionViewController = ScrollSessionViewController()
    public struct Provider: Dep {
        public func create(r: Registry) -> ScrollSessionViewController  {
            return ScrollSessionViewController.shared
        }
        public init() {}
    }

    private let logger: Logger = Logger(label: "industries.strange.slowdown.ScrollSessionView")
    @Published public var open: Bool = false

    @MainActor
    public func setOpen() {
        self.open = true
    }

    @MainActor
    public func setClosed() {
        self.open = false
    }
}
