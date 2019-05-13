//
//  EthereumDataTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 13.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest

@testable import Ethereum

class EthDataTests: XCTestCase {
    
    func testInitialization() {
        let data1 = EthData(Data([0xab, 0xcf, 0x45, 0x01]))
        XCTAssertEqual(data1.data, Data([0xab, 0xcf, 0x45, 0x01]), "should initialize correctly")

        let data2 = EthData(Data([0xab, 0xcf, 0x45, 0x01]))
        XCTAssertEqual(data1, data2, "should be equatable")
        
        XCTAssertEqual(data1.hashValue, data2.hashValue, "should produce correct hashValues")
    }
    
    func testEthValueConvertible() {
        let data1 = try? EthData(ethereumValue: "0x01020304ff")
        XCTAssertNotNil(data1, "should initialize correctly")
        XCTAssertEqual(data1?.data, Data([0x01, 0x02, 0x03, 0x04, 0xff]), "should initialize correctly")
        XCTAssertEqual(data1?.hex, "0x01020304ff", "should initialize correctly")
        
        let data2 = try? EthData(ethereumValue: "0x")
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2?.data, Data([]), "should initialize correctly")
        XCTAssertEqual(data2?.hex, "0x", "should initialize correctly")
        
        XCTAssertThrowsError(try EthData(ethereumValue: true)) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization")
        }
        XCTAssertThrowsError(try EthData(ethereumValue: 123)) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization")
        }
        XCTAssertThrowsError(try EthData(ethereumValue: [true, false])) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization")
        }
        XCTAssertThrowsError(try EthData(ethereumValue: "//()...")) { err in
            XCTAssertEqual(err as! EthData.Error, EthData.Error.hexIsMalformed, "should be invalid initialization")
        }
        
        let data3 = Value.string("0xabffcc").data
        XCTAssertNotNil(data3, "should return correct data")
        XCTAssertEqual(data3?.hex, "0xabffcc", "should return correct data")
        XCTAssertEqual(data3?.data, Data([0xab, 0xff, 0xcc]), "should return correct data")
    }
}
