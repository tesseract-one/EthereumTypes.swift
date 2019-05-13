//
//  Data+EthereumTests.swift
//  Ethereum
//
//  Created by Yehor Popovych on 5/13/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//

import Foundation
import XCTest

@testable import Ethereum

class DataEthereumTests: XCTestCase {
    
    func testDataToTrimmedHex() {
        XCTAssertEqual(Data([0x01, 0x02, 0x03, 0x04]).trimmedHex, "0x1020304")
        XCTAssertEqual(Data([0x00, 0x01, 0x02, 0x03, 0x04]).trimmedHex, "0x1020304")
        XCTAssertEqual(Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x00]).trimmedHex, "0x102030400")
        XCTAssertEqual(Data().trimmedHex, "0x0")
        XCTAssertEqual(Data([]).trimmedHex, "0x0")
        XCTAssertEqual(Data([0x00]).trimmedHex, "0x0")
    }
    
    func testDataTrimZeroes() {
        XCTAssertEqual(Data([0x01, 0x02, 0x03, 0x04]).trimmedLeadingZeros, Data([0x01, 0x02, 0x03, 0x04]))
        XCTAssertEqual(Data([0x00, 0x01, 0x02, 0x03, 0x04]).trimmedLeadingZeros, Data([0x01, 0x02, 0x03, 0x04]))
        XCTAssertEqual(Data([0x00, 0x00, 0x01, 0x02, 0x03, 0x04]).trimmedLeadingZeros, Data([0x01, 0x02, 0x03, 0x04]))
        XCTAssertEqual(Data([0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x00]).trimmedLeadingZeros, Data([0x01, 0x02, 0x03, 0x04, 0x00]))
        XCTAssertEqual(Data([0x00]).trimmedLeadingZeros, Data([0x00]))
        XCTAssertEqual(Data([0x00, 0x00]).trimmedLeadingZeros, Data([0x00]))
    }
    
    func testDataFromTrimmedHex() {
        XCTAssertEqual(Data(trimmedHex: "0x1020304"),  Data([0x01, 0x02, 0x03, 0x04]))
        XCTAssertEqual(Data(trimmedHex: "0x0"),  Data([0x00]))
    }
}
