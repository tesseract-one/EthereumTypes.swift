//
//  RLPItemTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 03.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest

@testable import Ethereum

class RLPItemTests: XCTestCase {
    
    func expectNumber(_ uint: UInt, message: String) {
        let i: RLPItem = .uint(uint)
        let ret = i.uint
        XCTAssertNotNil(ret, message)
        guard let int = ret else { return }
        XCTAssertEqual(uint, int, message)
    }
    
    func testRlpItems() {
        self.expectNumber(15, message: "should be int 15")
        self.expectNumber(1000, message: "should be int 1000")
        self.expectNumber(65537, message: "should be int 65537")
        self.expectNumber(UInt(Int.max), message: "should be int Int.max")
        self.expectNumber(UInt.max, message: "should be int UInt.max")
        self.expectNumber(4_294_967_295, message: "should be int 4_294_967_295") // 32 bit platform support...
        
        let i1: RLPItem = .uint(0x8f2c6d9b)
        XCTAssertEqual(i1.bytes, Data([0x8f, 0x2c, 0x6d, 0x9b]), "should be int 4 as big endian bytes")
        
        let big2 = BigUInt(integerLiteral: 2).power(156)
        let i2: RLPItem = .bigUInt(big2)
        XCTAssertEqual(i2.bytes, Data([0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), "should be bigint 2 to the power of 156")
        XCTAssertEqual(i2.bigUInt, big2, "should be bigint 2 to the power of 156")
        XCTAssertNil(i2.uint, "should be bigint 2 to the power of 156")
        
        let big3: BigUInt = (0x10f000000000 << (6 * 8)) | (0xa0800402e00c)
        let i3: RLPItem = .bigUInt(big3)
        XCTAssertEqual(i3.bytes, Data([0x10, 0xf0, 0x00, 0x00, 0x00, 0x00, 0xa0, 0x80, 0x04, 0x02, 0xe0, 0x0c]), "should be a big bigint")
        XCTAssertEqual(i3.bigUInt, big3, "should be a big bigint")
        XCTAssertNil(i3.uint, "should be a big bigint")
    }
}
