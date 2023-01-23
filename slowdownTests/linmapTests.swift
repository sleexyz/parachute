//
//  linmapTests.swift
//  slowdownTests
//
//  Created by Sean Lee on 1/23/23.
//

import Foundation
import XCTest
@testable import slowdown

class linmapTests: XCTestCase {
    func testLinear() throws {
        XCTAssertEqual(3.linmap(0, 10, 0,100), 30)
        XCTAssertEqual(13.linmap(0, 10, 0,100), 130)
        XCTAssertEqual(13.linmap(0, 10, 0,100, clip: true), 100)
        
    }
    func testExponential() throws {
        XCTAssertEqual(0.linmap(0, 10, 1,100,warp: .exponential), 1)
        XCTAssertEqual(5.linmap(0, 10, 1,100,warp: .exponential), 10)
        XCTAssertEqual(10.linmap(0, 10, 1,100,warp: .exponential), 100)
        XCTAssertEqual(15.linmap(0, 10, 1,100,warp: .exponential), 1000)
        XCTAssertEqual(20.linmap(0, 10, 1,100,warp: .exponential), 10000)
    }
    func testExponentialInverse() throws {
        XCTAssertEqual(0.linmap(0, 10, 100,1,warp: .exponential), 100)
        XCTAssertEqual(5.linmap(0, 10, 100,1,warp: .exponential), 10)
        XCTAssertEqual(10.linmap(0, 10, 100,1,warp: .exponential), 1)
        XCTAssertEqual(15.linmap(0, 10, 100,1,warp: .exponential), 0.1)
        XCTAssertEqual(20.linmap(0, 10, 100,1,warp: .exponential), 0.01)
    }
}
