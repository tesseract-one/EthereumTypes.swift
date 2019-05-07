//
//  ABIConvertibleTests.swift
//  Web3_Tests
//
//  Created by Josh Pyles on 5/29/18.
//

import XCTest
import BigInt

@testable import Ethereum

class ABIConvertibleTests: XCTestCase {
    
    func testSolidityRepresentable() {
        XCTAssertEqual(SolidityType.type(.string), String.solidityType, "should work with String")
        XCTAssertEqual(SolidityType.type(.bool), Bool.solidityType, "should work with Bool")
        XCTAssertEqual(SolidityType.type(.uint16), UInt16.solidityType, "should work with UInt16")
        XCTAssertEqual(SolidityType.type(.uint256), BigUInt.solidityType, "should work with BigUInt")
        XCTAssertEqual(SolidityType.type(.int8), Int8.solidityType, "should work with Int8")
        XCTAssertEqual(SolidityType.type(.int256), BigInt.solidityType, "should work with BigInt")
        XCTAssertEqual(SolidityType.type(.address), Address.solidityType, "should work with Address")
    }
    
    func testUnsignedIntegers() {
        let u8 = UInt8(255)
        let u16 = UInt16(255)
        let u32 = UInt32(255)
        let u64 = UInt64(255)
        let u256 = BigUInt(255)
        
        let eu8 = u8.abiEncode(dynamic: false)
        let eu16 = u16.abiEncode(dynamic: false)
        let eu32 = u32.abiEncode(dynamic: false)
        let eu64 = u64.abiEncode(dynamic: false)
        let eu256 = u256.abiEncode(dynamic: false)
        
        let expected = "00000000000000000000000000000000000000000000000000000000000000ff"
        
        XCTAssertEqual(eu8, expected, "should encode UInt8")
        XCTAssertEqual(eu16, expected, "should encode UInt16")
        XCTAssertEqual(eu32, expected, "should encode UInt32")
        XCTAssertEqual(eu64, expected, "should encode UInt64")
        XCTAssertEqual(eu256, expected, "should encode BigUInt")
        
        XCTAssertEqual(UInt8(hexString: expected), 255, "should decode UInt8")
        XCTAssertEqual(UInt16(hexString: expected), 255, "should decode UInt16")
        XCTAssertEqual(UInt32(hexString: expected), 255, "should decode UInt32")
        XCTAssertEqual(UInt64(hexString: expected), 255, "should decode UInt64")
        XCTAssertEqual(BigUInt(hexString: expected), 255, "should decode BigUInt")
    }
    
    func testSignedIntegers() {
        let int = Int8(-128)
        let positive = Int8(120)
        XCTAssertEqual(int.twosComplementRepresentation, 0, "should have correct twos complement representation")
        XCTAssertEqual(positive.twosComplementRepresentation, positive, "should have correct twos complement representation")
        XCTAssertEqual(Int8(twosComplementString: "10000000"), int, "should be able to be converted from twos string")
        XCTAssertEqual(Int8(twosComplementString: "01111111"), 127, "should be able to be converted from twos string")
        
        XCTAssertNil(Int8(twosComplementString: "FF"), "should fail to decode invalid strings")
        XCTAssertNil(BigInt(twosComplementString: "XYZZ"), "should fail to decode invalid strings")
    }
    
    func testSignedIntegersEncodeHex() {
        {
            let test1 = Int32(-1200).abiEncode(dynamic: false)
            let expected1 = "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb50"
            XCTAssertEqual(test1, expected1, "should encode negative various integer types")
            
            let test2 = Int64(-600).abiEncode(dynamic: false)
            let expected2 = "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffda8"
            XCTAssertEqual(test2, expected2, "should encode negative various integer types")
        }();
        
        {
            let test = Int(32).abiEncode(dynamic: false)
            let expected = "0000000000000000000000000000000000000000000000000000000000000020"
            XCTAssertEqual(test, expected, "should encode positive various integer types")
        }();
        
        {
            let test = BigInt(-1).abiEncode(dynamic: false)
            let expected = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
            XCTAssertEqual(test, expected, "should encode negative BigInt")
        }();
        
        {
            let test = BigInt(240000000).abiEncode(dynamic: false)
            let expected = "000000000000000000000000000000000000000000000000000000000e4e1c00"
            XCTAssertEqual(test, expected, "should encode positive BigInt")
        }();
    }
    
    func testSignedIntegersDecodeHex() {
        XCTAssertEqual(Int(hexString: "0000000000000000000000000000000000000000000000000000000000000020"), 32, "should decode Int")
        XCTAssertEqual(Int32(hexString: "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffb50"), -1200, "should decode negative values")
        XCTAssertEqual(Int64(hexString: "fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffda8"), -600, "should decode negative values")
        XCTAssertEqual(BigInt(hexString: "000000000000000000000000000000000000000000000000000000000e4e1c00"), BigInt(240000000), "should decode BigInt values")
        XCTAssertEqual(BigInt(hexString: "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"), BigInt(-1), "should decode negative BigInt values")
    }
    
    func testBool() {
        XCTAssertEqual(true.abiEncode(dynamic: false), "0000000000000000000000000000000000000000000000000000000000000001", "should encode true")
        XCTAssertEqual(false.abiEncode(dynamic: false), "0000000000000000000000000000000000000000000000000000000000000000", "should encode false")
        XCTAssertEqual(Bool(hexString: "0000000000000000000000000000000000000000000000000000000000000001"), true, "should decode true")
        XCTAssertEqual(Bool(hexString: "0000000000000000000000000000000000000000000000000000000000000000"), false, "should decode false")
        XCTAssertNil(Bool(hexString: "HI"), "should not decode non hex strings")
    }
    
    func testString() {
        XCTAssertEqual("Hello World!".abiEncode(dynamic: true), "000000000000000000000000000000000000000000000000000000000000000c48656c6c6f20576f726c64210000000000000000000000000000000000000000", "encodes 'Hello World!'")
        XCTAssertEqual("What‘s happening?".abiEncode(dynamic: true), "000000000000000000000000000000000000000000000000000000000000001357686174e28098732068617070656e696e673f00000000000000000000000000", "encodes 'Whats happening?'")
        XCTAssertEqual(String(hexString: "000000000000000000000000000000000000000000000000000000000000000c48656c6c6f20576f726c64210000000000000000000000000000000000000000"), "Hello World!", "decodes 'Hello World!'")
        XCTAssertEqual(String(hexString: "000000000000000000000000000000000000000000000000000000000000001357686174e28098732068617070656e696e673f00000000000000000000000000"), "What‘s happening?", "decodes 'Whats happening?'")
        XCTAssertNil(String(hexString: "00000"), "does not decode invalid data")
    }
    
    func testAddress() {
        let test = try! Address(hex: "0x9F2c4Ea0506EeAb4e4Dc634C1e1F4Be71D0d7531")
        let hex = "0000000000000000000000009f2c4ea0506eeab4e4dc634c1e1f4be71d0d7531"
        XCTAssertEqual(test.abiEncode(dynamic: false), hex, "should be able to be encoded to hex")
        XCTAssertEqual(Address(hexString: hex), test, "should be able to be decoded from hex")
        XCTAssertNil(Address(hexString: "0000000000000000000000009f2c4ea0506eeab4e4dc634c1e1f4be71d0d75XX"), "should not decode invalid data")
    }
    
    func testData() {
        let test1 = try? ABIEncoder.encode([.bytes(Data([1, 2, 3, 4, 5, 6, 7, 8, 9]))])
        let expected1 = "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000090102030405060708090000000000000000000000000000000000000000000000"
        XCTAssertEqual(test1, expected1, "should encode Data to dynamic bytes")
        
        let test2 = try? ABIEncoder.encode([.fixedBytes(Data([0, 111, 222]))])
        let expected2 = "006fde0000000000000000000000000000000000000000000000000000000000"
        XCTAssertEqual(test2, expected2, "should encode Data to fixed bytes")
        
        let test3 = "00000000000000000000000000000000000000000000000000000000000000090102030405060708090000000000000000000000000000000000000000000000"
        let expected3 = Data([1, 2, 3, 4, 5, 6, 7, 8, 9])
        XCTAssertEqual(Data(hexString: test3), expected3, "should decode Data from dynamic bytes")
        
        let test4 = "006fde0000000000000000000000000000000000000000000000000000000000"
        let expected4 = Data([0, 111, 222])
        XCTAssertEqual(Data(hexString: test4, length: 3), expected4, "should decode Data from fixed bytes")
    }
    
    func testArray() {
        let array: [Int64] = [0, 1, 2, 3]
        
        let test1 = array.abiEncode(dynamic: false)
        let expected1 = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        XCTAssertEqual(test1, expected1, "should encode as fixed array")
        
        let test2 = array.abiEncode(dynamic: true)
        let expected2 = "00000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        XCTAssertEqual(test2, expected2, "should encode as dynamic array")
        
        let string1 = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        let test3 = [Int64].init(hexString: string1, length: 4)
        XCTAssertEqual(test3, array, "should decode a fixed array")
        
        let string2 = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        let test4 = [Int64].init(hexString: string2)
        XCTAssertNil(test4, "should not decode a fixed array without a length")
        
        let string3 = "00000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        let test5: [Int64]? = [Int64].init(hexString: string3)
        XCTAssertEqual(test5, array, "should decode a dynamic array")
        
        let test6 = [Int64].init(hexString: "00000000000000", length: 100)
        XCTAssertNil(test6, "should not decode a fixed array with wrong amount of bytes")
    }
}
