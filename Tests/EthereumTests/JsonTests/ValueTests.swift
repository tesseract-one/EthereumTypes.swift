//
//  EthereumValueTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 13.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest
import Foundation

@testable import Ethereum

class ValueTests: XCTestCase {
    
    var encoder: JSONEncoder = JSONEncoder()
    var decoder: JSONDecoder = JSONDecoder()
    
    func testIntValues() {
        let value1: Value = 10
        let value2: Value = .int(100)
        let valueEdge1: Value = 0
        let valueEdge2: Value = 1
        let e1 = try? self.encoder.encode([value1, value2, valueEdge1, valueEdge2])
        XCTAssertNotNil(e1, "should encode successfully")
        guard let encoded1 = e1 else { return }
        XCTAssertEqual(String(bytes: encoded1, encoding: .utf8), "[10,100,0,1]", "should encode successfully")
        
        let encoded2 = "[10,100,0,1]"
        let decoded2 = try? self.decoder.decode(Value.self, from: Data(encoded2.bytes))
        XCTAssertNotNil(decoded2, "should decode successfully")
        XCTAssertEqual(decoded2?.array?.count, 4, "should decode successfully")
        XCTAssertEqual(decoded2?.array?[safe: 0]?.int, 10, "should decode successfully")
        XCTAssertEqual(decoded2?.array?[safe: 1]?.int, 100, "should decode successfully")
        XCTAssertNil(decoded2?.array?[safe: 2]?.bool, "should decode successfully")
        XCTAssertNil(decoded2?.array?[safe: 3]?.bool, "should decode successfully")
        XCTAssertEqual(decoded2?.array?[safe: 2]?.int, 0, "should decode successfully")
        XCTAssertEqual(decoded2?.array?[safe: 3]?.int, 1, "should decode successfully")
        
        let value3: Value = 10
        XCTAssertEqual(value3.hashValue, Value(integerLiteral: 10).hashValue, "should produce correct hashValue")
    }
    
    func testBoolValues() {
        let value1: Value = true
        let value2: Value = .bool(false)
        let e1 = try? self.encoder.encode([value1, value2])
        XCTAssertNotNil(e1, "should encode successfully")
        guard let encoded1 = e1 else { return }
        XCTAssertEqual(String(bytes: encoded1, encoding: .utf8), "[true,false]", "should encode successfully")
        
        let encoded2 = "[true,false]"
        let decoded2 = try? self.decoder.decode(Value.self, from: Data(encoded2.bytes))
        XCTAssertNotNil(decoded2, "should decode successfully")
        XCTAssertEqual(decoded2?.array?.count, 2, "should decode successfully")
        XCTAssertEqual(decoded2?.array?[safe: 0]?.bool, true, "should decode successfully")
        XCTAssertEqual(decoded2?.array?[safe: 1]?.bool, false, "should decode successfully")
        XCTAssertNil(decoded2?.array?[safe: 0]?.int, "should decode successfully")
        XCTAssertNil(decoded2?.array?[safe: 0]?.array, "should decode successfully")
        XCTAssertNil(decoded2?.array?[safe: 0]?.string, "should decode successfully")
        
        let value3: Value = true
        XCTAssertEqual(value3.hashValue, Value(booleanLiteral: true).hashValue, "should produce correct hashValue")
        let value4: Value = false
        XCTAssertEqual(value4.hashValue, Value(booleanLiteral: false).hashValue, "should produce correct hashValue")
    }
    
    func testNilValues() {
        let value1 = Value(type: .nil)
        let e1 = try? self.encoder.encode([value1, value1])
        XCTAssertNotNil(e1, "should encode successfully")
        guard let encoded1 = e1 else { return }
        XCTAssertEqual(String(bytes: encoded1, encoding: .utf8), "[null,null]", "should encode successfully")
        
        let encdoded2 = "[null,null]"
        let decoded2 = try? self.decoder.decode(Value.self, from: Data(encdoded2.bytes))
        XCTAssertEqual(decoded2?.array?.count, 2, "should encode successfully")
        XCTAssertEqual(decoded2?.array?[safe: 0]?.valueType, .nil, "should decode successfully")
        XCTAssertEqual(decoded2?.array?[safe: 1]?.valueType, .nil, "should decode successfully")
        XCTAssertNil(decoded2?.array?[safe: 0]?.int, "should decode successfully")
        XCTAssertNil(decoded2?.array?[safe: 0]?.array, "should decode successfully")
        XCTAssertNil(decoded2?.array?[safe: 0]?.string, "should decode successfully")
        XCTAssertNil(decoded2?.array?[safe: 0]?.bool, "should decode successfully")
    }
    
    func testArrayValues() {
        let value1: Value = .array([
            [] as Value,
            [] as Value,
            [] as Value,
            ["hello"] as Value,
            [100] as Value,
            false,
            [true] as Value,
            0,
            1
        ])
        let j1 = try? self.encoder.encode(value1)
        XCTAssertNotNil(j1, "should encode successfully")
        guard let json1 = j1 else { return }
        XCTAssertEqual(String(bytes: json1, encoding: .utf8), "[[],[],[],[\"hello\"],[100],false,[true],0,1]", "should encode successfully")
        
        let json2 = "[[],[],[],[\"hello\"],[100],false,[true],0,1]"
        let value2 = try? self.decoder.decode(Value.self, from: Data(json2.bytes))
        XCTAssertNotNil(value2, "should decode successfully")
        XCTAssertEqual(value2?.array?.count, 9, "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 0]?.array?.count, 0, "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 1]?.array?.count, 0, "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 2]?.array?.count, 0, "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 3]?.array?.count, 1, "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 3]?.array?[safe: 0]?.string, "hello", "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 4]?.array?.count, 1, "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 4]?.array?[safe: 0]?.int, 100, "should decode successfully")
        XCTAssertNil(value2?.array?[safe: 5]?.array, "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 5]?.bool, false, "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 6]?.array?.count, 1, "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 6]?.array?[safe: 0]?.bool, true, "should decode successfully")
        XCTAssertNil(value2?.array?[safe: 7]?.array, "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 7]?.int, 0, "should decode successfully")
        XCTAssertNil(value2?.array?[safe: 8]?.array, "should decode successfully")
        XCTAssertEqual(value2?.array?[safe: 8]?.int, 1, "should decode successfully")
        
        let value3: Value = .array([
            [] as Value,
            [] as Value,
            [] as Value,
            ["hello"] as Value,
            [100] as Value,
            false,
            [true] as Value,
            0,
            1
        ])
        let value4: Value = .array([
            [] as Value,
            [] as Value,
            [] as Value,
            ["hello"] as Value,
            [100] as Value,
            false,
            [true] as Value,
            0,
            1
        ])
        XCTAssertEqual(value3.hashValue, value4.hashValue, "should produce correct hashValue")
    }
    
    func testValueConvertibility() {
        let ethereumValue1 = try? Value(ethereumValue: 10)
        XCTAssertEqual(ethereumValue1?.int, 10, "should initialize itself")
        
        let ethereumValue2: Value = Value.bool(true).ethereumValue()
        XCTAssertEqual(ethereumValue2.bool, true, "should return itself")
    }
    
    func testTypesValueConvertibility() {
        let value1 = true.ethereumValue()
        let value2 = false.ethereumValue()
        XCTAssertEqual(value1.bool, true, "should initialize and return bool")
        XCTAssertEqual(value2.bool, false, "should initialize and return bool")
        let returnValue1 = try? Bool(ethereumValue: value1)
        let returnValue2 = try? Bool(ethereumValue: value2)
        XCTAssertNotNil(returnValue1, "should initialize and return bool")
        XCTAssertEqual(returnValue1, true, "should initialize and return bool")
        XCTAssertNotNil(returnValue2, "should initialize and return bool")
        XCTAssertEqual(returnValue2, false, "should initialize and return bool")
        
        XCTAssertThrowsError(try Bool(ethereumValue: 28)) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization of Bool")
        }
        XCTAssertThrowsError(try Bool(ethereumValue: [true, false])) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization of Bool")
        }
        XCTAssertThrowsError(try Bool(ethereumValue: "meh,meh,meh")) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization of Bool")
        }
        
        let value3 = "xD".ethereumValue()
        let value4 = "0x0123456789abcdef".ethereumValue()
        XCTAssertEqual(value3.string, "xD", "should initialize and return string")
        XCTAssertEqual(value4.string, "0x0123456789abcdef", "should initialize and return string")
        let returnValue3 = try? String(ethereumValue: value3)
        let returnValue4 = try? String(ethereumValue: value4)
        XCTAssertNotNil(returnValue3, "should initialize and return string")
        XCTAssertEqual(returnValue3, "xD", "should initialize and return string")
        XCTAssertNotNil(returnValue4, "should initialize and return string")
        XCTAssertEqual(returnValue4, "0x0123456789abcdef", "should initialize and return string")
        
        XCTAssertThrowsError(try String(ethereumValue: 97)) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization of String")
        }
        XCTAssertThrowsError(try String(ethereumValue: [true, false])) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization of String")
        }
        XCTAssertThrowsError(try String(ethereumValue: true)) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization of String")
        }
        XCTAssertThrowsError(try String(ethereumValue: false)) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization of String")
        }
        
        let value5 = 19.ethereumValue()
        let value6 = 22.ethereumValue()
        XCTAssertEqual(value5.int, 19, "should initialize and return int")
        XCTAssertEqual(value6.int, 22, "should initialize and return int")
        let returnValue5 = try? Int(ethereumValue: value5)
        let returnValue6 = try? Int(ethereumValue: value6)
        XCTAssertNotNil(returnValue5, "should initialize and return int")
        XCTAssertEqual(returnValue5, 19, "should initialize and return int")
        XCTAssertNotNil(returnValue6, "should initialize and return int")
        XCTAssertEqual(returnValue6, 22, "should initialize and return int")
        
        XCTAssertThrowsError(try Int(ethereumValue: "...-/-...")) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization of Int")
        }
        XCTAssertThrowsError(try Int(ethereumValue: [true, false])) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization of Int")
        }
        XCTAssertThrowsError(try Int(ethereumValue: true)) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization of Int")
        }
        XCTAssertThrowsError(try Int(ethereumValue: false)) { err in
            XCTAssertEqual(err as! ValueInitializableError, ValueInitializableError.notInitializable, "should be invalid initialization of Int")
        }
    }
}

fileprivate extension Collection {

    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
