//
//  RLPDecoderTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 04.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest

@testable import Ethereum

class RLPDecoderTests: XCTestCase {
    let decoder = RLPDecoder()
    
    func testStringsAndBytes() {
        let bytes1: Data = Data([0x83, 0x64, 0x6f, 0x67])
        let i1 = try? decoder.decode(bytes1)
        XCTAssertNotNil(i1, "should be dog")
        guard let item1 = i1 else { return }
        XCTAssertEqual(item1.bytes, Data([0x64, 0x6f, 0x67]), "should be dog")
        XCTAssertEqual(item1.string, "dog", "should be dog")
        
        let i2 = try? decoder.decode(Data([0x80]))
        XCTAssertNotNil(i2, "should be the empty string")
        guard let item2 = i2 else { return }
        XCTAssertEqual(item2.bytes, Data([]), "should be the empty string")
        XCTAssertEqual(item2.string, "", "should be the empty string")
        
        let i3 = try? decoder.decode(Data([0x00]))
        XCTAssertNotNil(i3, "should be the byte 0x00")
        guard let item3 = i3 else { return }
        XCTAssertEqual(item3.bytes, Data([0x00]), "should be the byte 0x00")
        XCTAssertEqual(item3.uint, 0, "should be the byte 0x00")
        
        let i4 = try? decoder.decode(Data([0x0f]))
        XCTAssertNotNil(i4, "should be the integer 15")
        guard let item4 = i4 else { return }
        XCTAssertEqual(item4.bytes, Data([0x0f]), "should be the integer 15")
        XCTAssertEqual(item4.uint, 15, "should be the integer 15")
        
        let i5 = try? decoder.decode(Data([0x82, 0x04, 0x00]))
        XCTAssertNotNil(i5, "should be the integer 15")
        guard let item5 = i5 else { return }
        XCTAssertEqual(item5.bytes, UInt(1024).data.trimmedLeadingZeros, "should be the integer 1024")
        XCTAssertEqual(item5.uint, 1024, "should be the integer 1024")
        
        let str6 = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
        let strBytes6 = str6.data(using: .utf8)!
        var rlp6 = Data([0xb8, 0x38])
        for b in strBytes6 { rlp6.append(b) }
        let i6 = try? decoder.decode(rlp6)
        XCTAssertNotNil(i6, "should be the long latin string")
        guard let item6 = i6 else { return }
        XCTAssertEqual(item6.bytes, strBytes6, "should be the long latin string")
        XCTAssertEqual(item6.string, str6, "should be the long latin string")
        
        let hex7 = Data(hex: "f86d808504e3b29200825208943011f9a95fe30585ec5b3a555a62a51fab941b16890138400eca364a00008026a063b2edbba05d7b2e26d97174553478724b9c305323a67fee43fd333a1e336f06a0389874858c39fddf5437220d90531c649f0da592403df0c1915cb0f720535e0a")
        XCTAssertNotNil(hex7, "should be a signed transaction")
        let i7 = try? decoder.decode(hex7)
        XCTAssertNotNil(i7, "should be a signed transaction")
        guard let item7 = i7 else { return }
        XCTAssertEqual(item7.array?[safe: 0]?.bytes, Data([]), "should be a signed transaction")
        XCTAssertEqual(item7.array?[safe: 1]?.bytes, Data([0x4, 0xe3, 0xb2, 0x92, 0x0]), "should be a signed transaction")
        XCTAssertEqual(item7.array?[safe: 2]?.bytes, Data([0x52, 0x8]), "should be a signed transaction")
        XCTAssertEqual(item7.array?[safe: 3]?.bytes, Data([0x30, 0x11, 0xf9, 0xa9, 0x5f, 0xe3, 0x5, 0x85, 0xec, 0x5b, 0x3a, 0x55, 0x5a, 0x62, 0xa5, 0x1f, 0xab, 0x94, 0x1b, 0x16]), "should be a signed transaction")
        XCTAssertEqual(item7.array?[safe: 4]?.bytes, Data([0x1, 0x38, 0x40, 0xe, 0xca, 0x36, 0x4a, 0x0, 0x0]), "should be a signed transaction")
        XCTAssertEqual(item7.array?[safe: 5]?.bytes, Data([]), "should be a signed transaction")
        XCTAssertEqual(item7.array?[safe: 6]?.bytes, Data([0x26]), "should be a signed transaction")
        XCTAssertEqual(item7.array?[safe: 7]?.bytes, Data([0x63, 0xb2, 0xed, 0xbb, 0xa0, 0x5d, 0x7b, 0x2e, 0x26, 0xd9, 0x71, 0x74, 0x55, 0x34, 0x78, 0x72, 0x4b, 0x9c, 0x30, 0x53, 0x23, 0xa6, 0x7f, 0xee, 0x43, 0xfd, 0x33, 0x3a, 0x1e, 0x33, 0x6f, 0x6]), "should be a signed transaction")
        XCTAssertEqual(item7.array?[safe: 8]?.bytes, Data([0x38, 0x98, 0x74, 0x85, 0x8c, 0x39, 0xfd, 0xdf, 0x54, 0x37, 0x22, 0xd, 0x90, 0x53, 0x1c, 0x64, 0x9f, 0xd, 0xa5, 0x92, 0x40, 0x3d, 0xf0, 0xc1, 0x91, 0x5c, 0xb0, 0xf7, 0x20, 0x53, 0x5e, 0xa]), "should be a signed transaction")
    }
    
    func testListItems() {
        let rlp1 = Data([0xc8, 0x83, 0x63, 0x61, 0x74, 0x83, 0x64, 0x6f, 0x67])
        let i1 = try? decoder.decode(rlp1)
        XCTAssertNotNil(i1, "should be cat and dog")
        guard let item1 = i1 else { return }
        let a1 = item1.array
        XCTAssertNotNil(a1, "should be cat and dog")
        guard let arr1 = a1 else { return }
        XCTAssertEqual(arr1.count, 2, "should be cat and dog")
        guard arr1.count == 2 else { return }
        XCTAssertEqual(arr1[0].bytes, Data([0x63, 0x61, 0x74]), "should be cat and dog")
        XCTAssertEqual(arr1[0].string, "cat", "should be cat and dog")
        XCTAssertEqual(arr1[1].bytes, Data([0x64, 0x6f, 0x67]), "should be cat and dog")
        XCTAssertEqual(arr1[1].string, "dog", "should be cat and dog")
        
        let i2 = try? decoder.decode(Data([0xc0]))
        XCTAssertNotNil(i2, "should be the empty list")
        guard let item2 = i2 else { return }
        XCTAssertNotNil(item2, "should be the empty list")
        XCTAssertEqual(item2.array?.count, 0, "should be the empty list")
        
        let rlp3 = Data([0xc7, 0xc0, 0xc1, 0xc0, 0xc3, 0xc0, 0xc1, 0xc0])
        let i3 = try? decoder.decode(rlp3)
        XCTAssertNotNil(i3, "should be the set theoretical representation of three")
        guard let item3 = i3 else { return }
        XCTAssertEqual(item3.array?.count, 3, "should be the set theoretical representation of three")
        XCTAssertEqual(item3.array?[safe: 0]?.array?.count, 0, "should be the set theoretical representation of three")
        XCTAssertEqual(item3.array?[safe: 1]?.array?.count, 1, "should be the set theoretical representation of three")
        XCTAssertEqual(item3.array?[safe: 1]?.array?[safe: 0]?.array?.count, 0, "should be the set theoretical representation of three")
        XCTAssertEqual(item3.array?[safe: 2]?.array?.count, 2, "should be the set theoretical representation of three")
        XCTAssertEqual(item3.array?[safe: 2]?.array?[safe: 0]?.array?.count, 0, "should be the set theoretical representation of three")
        XCTAssertEqual(item3.array?[safe: 2]?.array?[safe: 1]?.array?.count, 1, "should be the set theoretical representation of three")
        XCTAssertEqual(item3.array?[safe: 2]?.array?[safe: 1]?.array?[safe: 0]?.array?.count, 0, "should be the set theoretical representation of three")
        
        let str4 = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
        let strBytes4 = str4.data(using: .utf8)!
        var rlp4 = Data([0xf8, 0x74])
        for _ in 0..<2 {
            rlp4.append(0xb8)
            rlp4.append(0x38)
            for b in strBytes4 { rlp4.append(b) }
        }
        let item4 = try? decoder.decode(rlp4)
        XCTAssertNotNil(item4, "should be an array of long latin strings")
        XCTAssertEqual(item4?.array?[safe: 0]?.bytes, strBytes4, "should be an array of long latin strings")
        XCTAssertEqual(item4?.array?[safe: 0]?.string, str4, "should be an array of long latin strings")
        XCTAssertEqual(item4?.array?[safe: 1]?.bytes, strBytes4, "should be an array of long latin strings")
        XCTAssertEqual(item4?.array?[safe: 1]?.string, str4, "should be an array of long latin strings")
    }
}

fileprivate extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
