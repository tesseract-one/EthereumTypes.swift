//
//  UInt+BytesRepresentableTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 01.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest

@testable import Ethereum

class UIntBytesRepresentableTests: XCTestCase {
    
    func testUintDataRepresentation() {
        let zero = UInt(0).data
        XCTAssertEqual(zero.count, MemoryLayout<UInt>.size, "should be zero")
        guard zero.count == MemoryLayout<UInt>.size else { return }
        for i in 0..<MemoryLayout<UInt>.size {
            XCTAssertEqual(zero[i], 0x00, "should be zero")
        }
        
        let max = UInt.max.data
        XCTAssertEqual(max.count, MemoryLayout<UInt>.size, "should be uint max")
        guard max.count == MemoryLayout<UInt>.size else { return }
        // For uint max value is 1111 1111 ....
        for i in 0..<MemoryLayout<UInt>.size {
            XCTAssertEqual(max[i], 0xff, "should be uint max")
        }
        
        let two = UInt(1024).data
        XCTAssertEqual(two.count, MemoryLayout<UInt>.size, "should be 0x0400")
        guard two.count == MemoryLayout<UInt>.size else { return }
        for i in 0..<MemoryLayout<UInt>.size - 2 {
            XCTAssertEqual(two[i], 0x00, "should be 0x0400")
        }
        XCTAssertEqual(two[MemoryLayout<UInt>.size - 2], 0x04, "should be 0x0400")
        XCTAssertEqual(two[MemoryLayout<UInt>.size - 1], 0x00, "should be 0x0400")
    }
}
