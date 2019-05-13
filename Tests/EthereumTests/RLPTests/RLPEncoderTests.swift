//
//  RLPEncoderTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 03.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest

@testable import Ethereum

class RLPEncoderTests: XCTestCase {
    let encoder = RLPEncoder()
    
    func expectCount(_ rlp: Data?, count: Int) -> Data? {
        XCTAssertNotNil(rlp, "expectCount: rlp shouldn't be nil")
        guard let r = rlp else { return nil }
        
        XCTAssertEqual(r.count, count, "expectCount: r should be equal to rlp")
        guard r.count == count else { return nil }
        
        return r
    }
    
    func expectBasicRLPString(prefix: UInt8, string: String, rlp: Data) {
        let stringBytes = string.data(using: .utf8)!.bytes
        let rlpBytes = rlp.bytes
        let rlpHead = rlpBytes[0]
        let rlpTail = Array(rlpBytes[1...])
        XCTAssertEqual(stringBytes.count, rlpTail.count, "expectBasicRLPString: rlpTail not equal to string bytes length")
        guard stringBytes.count == rlpTail.count else { return }

        XCTAssertEqual(prefix, rlpHead, "expectBasicRLPString: prefix not equal to rlpHead")
        XCTAssertEqual(rlpTail, stringBytes, "expectBasicRLPString: rlpTail not equal to string bytes")
    }
    
    func expectGeneralRLPString(string: String, rlp: Data) {
        let stringBytes = string.data(using: .utf8)!
        XCTAssertEqual(stringBytes.count, rlp.count, "expectGeneralRLPString: rlp length not equal to string bytes length")
        guard stringBytes.count == rlp.count else { return }
        
        XCTAssertEqual(rlp, stringBytes, "expectGeneralRLPString: rlp should be as string bytes")
    }
    
    func testStringsAndBytes() {
        let r1 = try? encoder.encode("dog")
        guard let rlp1 = self.expectCount(r1, count: 4) else { return }
        XCTAssertEqual(rlp1[0], 0x83, "should be dog as rlp")
        XCTAssertEqual(rlp1[1], 0x64, "should be dog as rlp")
        XCTAssertEqual(rlp1[2], 0x6f, "should be dog as rlp")
        XCTAssertEqual(rlp1[3], 0x67, "should be dog as rlp")
        
        let r2 = try? encoder.encode("")
        guard let rlp2 = self.expectCount(r2, count: 1) else { return }
        XCTAssertEqual(rlp2[0], 0x80, "should be the empty string")
        
        let r3 = try? encoder.encode(.bytes(0x00))
        guard let rlp3 = self.expectCount(r3, count: 1) else { return }
        XCTAssertEqual(rlp3[0], 0x00, "should be the encoded byte 0x00")
        
        let r4 = try? encoder.encode(15)
        guard let rlp4 = self.expectCount(r4, count: 1) else { return }
        XCTAssertEqual(rlp4[0], 0x0f, "should be the integer 15")
        
        let r5 = try? encoder.encode(1024)
        guard let rlp5 = self.expectCount(r5, count: 3) else { return }
        XCTAssertEqual(rlp5[0], 0x82, "should be the integer 1024")
        XCTAssertEqual(rlp5[1], 0x04, "should be the integer 1024")
        XCTAssertEqual(rlp5[2], 0x00, "should be the integer 1024")
        
        let str6 = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
        let r6 = try? encoder.encode(.string(str6))
        guard let rlp6 = self.expectCount(r6, count: 58) else { return }
        XCTAssertEqual(rlp6[0], 0xb8, "should be the long latin string")
        XCTAssertEqual(rlp6[1], 0x38, "should be the long latin string")
        let rlpString6 = rlp6[2..<58]
        self.expectGeneralRLPString(string: str6, rlp: rlpString6)
    }
    
    func testListItems() {
        let r1 = try? encoder.encode(["cat", "dog"])
        guard let rlp1 = self.expectCount(r1, count: 9) else { return }
        XCTAssertEqual(rlp1[0], 0xc8, "should be cat and dog as rlp list")
        let cat1 = rlp1[1..<5]
        self.expectBasicRLPString(prefix: 0x83, string: "cat", rlp: cat1)
        let dog1 = rlp1[5..<9]
        self.expectBasicRLPString(prefix: 0x83, string: "dog", rlp: dog1)
        
        let r2 = try? encoder.encode([])
        guard let rlp2 = self.expectCount(r2, count: 1) else { return }
        XCTAssertEqual(rlp2[0], 0xc0, "should be the empty list")
        
        let r3 = try? encoder.encode([ [], [[]], [ [], [[]] ] ])
        guard let rlp3 = self.expectCount(r3, count: 8) else { return }
        XCTAssertEqual(rlp3[0], 0xc7, "should be the set theoretical representation of three")
        XCTAssertEqual(rlp3[1], 0xc0, "should be the set theoretical representation of three")
        XCTAssertEqual(rlp3[2], 0xc1, "should be the set theoretical representation of three")
        XCTAssertEqual(rlp3[3], 0xc0, "should be the set theoretical representation of three")
        XCTAssertEqual(rlp3[4], 0xc3, "should be the set theoretical representation of three")
        XCTAssertEqual(rlp3[5], 0xc0, "should be the set theoretical representation of three")
        XCTAssertEqual(rlp3[6], 0xc1, "should be the set theoretical representation of three")
        XCTAssertEqual(rlp3[7], 0xc0, "should be the set theoretical representation of three")
        
        let str4 = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
        let r4 = try? encoder.encode([.string(str4), .string(str4)])
        guard let rlp4 = self.expectCount(r4, count: 118) else { return }
        XCTAssertEqual(rlp4[0], 0xf8, "should be an array of long latin strings")
        XCTAssertEqual(rlp4[1], 0x74, "should be an array of long latin strings")
        XCTAssertEqual(rlp4[2], 0xb8, "should be an array of long latin strings")
        XCTAssertEqual(rlp4[3], 0x38, "should be an array of long latin strings")
        let rlpStringOne4 = rlp4[4..<60]
        self.expectGeneralRLPString(string: str4, rlp: rlpStringOne4)
        XCTAssertEqual(rlp4[60], 0xb8, "should be an array of long latin strings")
        XCTAssertEqual(rlp4[61], 0x38, "should be an array of long latin strings")
        let rlpStringTwo4 = rlp4[62..<118]
        self.expectGeneralRLPString(string: str4, rlp: rlpStringTwo4)
    }
}
