//
//  EthereumAddressTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 05.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest

@testable import Ethereum

extension Address {
    static let testAddress = try! Address(hex: "0x0000000000000000000000000000000000000000", eip55: false)
}

class AddressTests: XCTestCase {

    func testWithoutEip55Checksum() {
        let a1 = try? Address(hex: "0xf5745ddac99ee7b70518a9035c00cfd63c490b1d", eip55: false)
        XCTAssertNotNil(a1, "should be valid ethereum addresses")
        XCTAssertEqual(a1?.hex(eip55: false), "0xf5745ddac99ee7b70518a9035c00cfd63c490b1d", "should be valid ethereum addresses")
        let a2 = try? Address(hex: "f5745ddac99ee7b70518a9035c00cfd63c490b1d", eip55: false)
        XCTAssertNotNil(a2, "should be valid ethereum addresses")
        XCTAssertEqual(a2?.hex(eip55: false), "0xf5745ddac99ee7b70518a9035c00cfd63c490b1d", "should be valid ethereum addresses")
        XCTAssertEqual(a1?.rawValue, a2?.rawValue, "should be valid ethereum addresses")
        let randomMixedCase = try? Address(hex: "0xf5745dDac99Ee7b70518A9035C00cfd63c490b1D", eip55: false)
        XCTAssertNotNil(randomMixedCase, "should be valid ethereum addresses")
        XCTAssertEqual(randomMixedCase?.hex(eip55: false), "0xf5745ddac99ee7b70518a9035c00cfd63c490b1d", "should be valid ethereum addresses")
        let zero = try? Address(hex: "0x0000000000000000000000000000000000000000", eip55: false)
        XCTAssertEqual(zero?.hex(eip55: false), "0x0000000000000000000000000000000000000000", "should be valid ethereum addresses")
        XCTAssertEqual(zero?.rawValue, Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]), "should be valid ethereum addresses")
        
        XCTAssertThrowsError(try Address(hex: "0xf5745ddac99ee7b70518a9035c00cfd63c490b1dd", eip55: false)) { err in
            XCTAssertEqual(err as! Address.Error, Address.Error.addressMalformed, "should be invalid ethereum addresses")
        }
        XCTAssertThrowsError(try Address(hex: "f5745ddac99ee7b70518a9035c00cfd63c490b1", eip55: false)) { err in
            XCTAssertEqual(err as! Address.Error, Address.Error.addressMalformed, "should be invalid ethereum addresses")
        }
        XCTAssertThrowsError(try Address(hex: "0xf5745ddac99ee7b70518a9035c00cfd63c490b1", eip55: false)) { err in
            XCTAssertEqual(err as! Address.Error, Address.Error.addressMalformed, "should be invalid ethereum addresses")
        }
        XCTAssertThrowsError(try Address(hex: "0xf5745ddac99ee7b70518a9035c00cfd63c490b", eip55: false)) { err in
            XCTAssertEqual(err as! Address.Error, Address.Error.addressMalformed, "should be invalid ethereum addresses")
        }
        XCTAssertThrowsError(try Address(hex: "f5745ddac99ee7b70518a9035c00cfd63c490b1ddd", eip55: false)) { err in
            XCTAssertEqual(err as! Address.Error, Address.Error.addressMalformed, "should be invalid ethereum addresses")
        }
    }
    
    func testWithEip55Checksum() {
        let a1 = try? Address(hex: "0xf5745DDAC99EE7B70518A9035c00cfD63C490B1D", eip55: true)
        XCTAssertNotNil(a1, "should be valid checksumed ethereum addresses")
        XCTAssertEqual(a1?.hex(eip55: true), "0xf5745DDAC99EE7B70518A9035c00cfD63C490B1D", "should be valid checksumed ethereum addresses")
        let a2 = try? Address(hex: "f5745DDAC99EE7B70518A9035c00cfD63C490B1D", eip55: true)
        XCTAssertNotNil(a2, "should be valid checksumed ethereum addresses")
        XCTAssertEqual(a2?.hex(eip55: true), "0xf5745DDAC99EE7B70518A9035c00cfD63C490B1D", "should be valid checksumed ethereum addresses")
        XCTAssertEqual(a1?.rawValue, a2?.rawValue, "should be valid checksumed ethereum addresses")
        
        XCTAssertThrowsError(try Address(hex: "0xf5745DDAC99EE7B70518A9035c00cfD63C490B1d", eip55: true)) { err in
            XCTAssertEqual(err as! Address.Error, Address.Error.checksumWrong, "should be invalid checksumed ethereum addresses")
        }
        XCTAssertThrowsError(try Address(hex: "0xf5745dDAC99EE7B70518A9035c00cfD63C490B1D", eip55: true)) { err in
            XCTAssertEqual(err as! Address.Error, Address.Error.checksumWrong, "should be invalid checksumed ethereum addresses")
        }
        XCTAssertThrowsError(try Address(hex: "0xf5745ddac99ee7b70518a9035c00cfd63c490b1d", eip55: true)) { err in
            XCTAssertEqual(err as! Address.Error, Address.Error.checksumWrong, "should be invalid checksumed ethereum addresses")
        }
    }
        
    func testHashability() {
        let a1 = try? Address(hex: "0xf5745ddac99ee7b70518a9035c00cfd63c490b1d", eip55: false)
        let a2 = try? Address(hex: "0xf5745ddac99ee7b70518a9035c00cfd63c490b1d", eip55: false)
        XCTAssertEqual(a1?.hashValue, a2?.hashValue, "should produce correct hashValues")
    }
}
