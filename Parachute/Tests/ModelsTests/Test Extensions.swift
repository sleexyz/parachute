//
//  File.swift
//
//
//  Created by Sean Lee on 9/26/23.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { self }
}
