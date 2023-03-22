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
    func testNegativeRange() throws {
        XCTAssertEqual(3.applyMapping(Mapping(a: 0, b: 10, c: -100, d: 100)), -40)
    }
    func testLinear() throws {
        XCTAssertEqual(3.applyMapping ( Mapping(a: 0, b: 10, c: 0, d: 100)), 30)
        XCTAssertEqual(13.applyMapping( Mapping(a: 0, b: 10, c: 0, d: 100)), 130)
        XCTAssertEqual(13.applyMapping( Mapping(a: 0, b: 10, c: 0, d: 100,clip: true)), 100)
        
    }
    func testOutWarpExponential() throws {
        let mapping = Mapping(a: 0, b: 10, c: 1, d: 100, outWarp: .exponential)
        XCTAssertEqual( 0.applyMapping(mapping), 1)
        XCTAssertEqual( 5.applyMapping(mapping), 10)
        XCTAssertEqual(10.applyMapping(mapping), 100)
        XCTAssertEqual(15.applyMapping(mapping), 1000)
        XCTAssertEqual(20.applyMapping(mapping), 10000)
    }
    func testOutWarpExponentialNegative() throws {
        let mapping = Mapping(a: 0, b: 10, c: 100, d: 1, outWarp: .exponential)
        XCTAssertEqual( 0.applyMapping(mapping), 100)
        XCTAssertEqual( 5.applyMapping(mapping), 10)
        XCTAssertEqual(10.applyMapping(mapping), 1)
        XCTAssertEqual(15.applyMapping(mapping), 0.1)
        XCTAssertEqual(20.applyMapping(mapping), 0.01)
    }
    
    func testInWarpExponential() throws {
        let mapping = Mapping(a: 1, b: 100, c: 0, d: 10, inWarp: .exponential)
        XCTAssertEqual(    1.applyMapping(mapping), 0)
        XCTAssertEqual(   10.applyMapping(mapping), 5)
        XCTAssertEqual(  100.applyMapping(mapping), 10)
        XCTAssertEqual( 1000.applyMapping(mapping), 15,accuracy: 0.001)
        XCTAssertEqual(10000.applyMapping(mapping), 20)
    }
    
    func testInverse() throws {
        let mapping = Mapping(a: 1, b: 100, c: 0, d: 10, inWarp: .exponential)
        let inverse = mapping.inverse
        XCTAssertEqual(1.applyMapping(mapping).applyMapping(inverse), 1, accuracy: 0.001)
        XCTAssertEqual(10.applyMapping(mapping).applyMapping(inverse), 10, accuracy: 0.001)
        XCTAssertEqual(100.applyMapping(mapping).applyMapping(inverse), 100, accuracy: 0.001)
        XCTAssertEqual(1000.applyMapping(mapping).applyMapping(inverse), 1000, accuracy: 0.001)
        XCTAssertEqual(10000.applyMapping(mapping).applyMapping(inverse), 10000, accuracy: 0.001)
    }
}
