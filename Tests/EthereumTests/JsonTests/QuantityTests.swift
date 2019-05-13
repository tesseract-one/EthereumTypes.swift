//
//  EthereumQuantityTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 13.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest
import BigInt

@testable import Ethereum

class QuantityTests: XCTestCase {
    
    func testInitialization() {
        let q1 = Quantity(data: Data([0x25, 0xcc, 0xe9, 0xf5]))
        XCTAssertEqual(q1.quantity, BigUInt(634186229), "should initialize correctly")
        
        let q2 = Quantity(BigUInt(100000000))
        XCTAssertEqual(q2.quantity, BigUInt(100000000), "should initialize correctly")
        
        let q3: Quantity = 2024
        XCTAssertEqual(q3.quantity, BigUInt(2024), "should initialize correctly")
        
        let q4 = try? Quantity.string("0x1234")
        XCTAssertNotNil(q4, "should initialize correctly")
        XCTAssertEqual(q4?.quantity, BigUInt(0x1234), "should initialize correctly")
        
        let q5 = try? Quantity(ethereumValue: "0x12345")
        XCTAssertNotNil(q5, "should initialize correctly")
        XCTAssertEqual(q5?.quantity, BigUInt(0x12345), "should initialize correctly")
    }
    
    func testConversions() {
        let q1 = Value.string("0x1234").quantity
        XCTAssertNotNil(q1, "should convert correctly from ethereum value")
        XCTAssertEqual(q1?.quantity, BigUInt(0x1234), "should convert correctly from ethereum value")
        XCTAssertNil(Value.bool(true).quantity, "should convert correctly from ethereum value")
        
        let q2 = try? Quantity.string("0x0")
        XCTAssertNotNil(q2, "should produce minimized hex strings")
        XCTAssertEqual(q2?.hex, "0x0", "should produce minimized hex strings")
        
        let q3 = try? Quantity.string("0x0")
        XCTAssertNotNil(q3, "should produce minimized hex strings")
        XCTAssertEqual(q3?.hex, "0x0", "should produce minimized hex strings")
        
        let q4 = try? Quantity.string("0x0123456")
        XCTAssertNotNil(q4, "should produce minimized hex strings")
        XCTAssertEqual(q4?.hex, "0x123456", "should produce minimized hex strings")
        
        let q5 = try? Quantity.string("0x000abcdef")
        XCTAssertNotNil(q5, "should produce minimized hex strings")
        XCTAssertEqual(q5?.hex, "0xabcdef", "should produce minimized hex strings")
    }
    
    func testHashability() {
        let q1 = Quantity(data: Data([0x25, 0xcc, 0xe9, 0xf5]))
        XCTAssertEqual(q1.hashValue, Quantity(data: Data([0x25, 0xcc, 0xe9, 0xf5])).hashValue, "should produce correct hashValues")
        
        let q2 = Quantity(BigUInt(100000000))
        XCTAssertEqual(q2.hashValue, Quantity(BigUInt(100000000)).hashValue, "should produce correct hashValues")
        
        let q3: Quantity = 2024
        XCTAssertEqual(q3.hashValue, Quantity(integerLiteral: 2024).hashValue, "should produce correct hashValues")
    }
}
