//
//  Cardable.swift
//  slowdown
//
//  Created by Sean Lee on 2/22/23.
//

import Foundation
import SwiftUI

protocol Cardable {
    associatedtype V: View
    @ViewBuilder
    func makeCard() -> V
}

