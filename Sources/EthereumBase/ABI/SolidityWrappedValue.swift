//
//  WrappedValue.swift
//  Web3
//
//  Created by Josh Pyles on 6/1/18.
//

import Foundation
import BigInt

/// Struct representing the combination of a SolidityType and a native value
struct SolidityWrappedValue {
    
     let value: ABIEncodable
     let type: SolidityType
    
     init(value: ABIEncodable, type: SolidityType) {
        self.value = value
        self.type = type
    }
    
    // Simple types
    
     static func string(_ value: String) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .string)
    }
    
     static func bool(_ value: Bool) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .bool)
    }
    
     static func address(_ value: Address) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .address)
    }
    
    // UInt
    
     static func uint(_ value: BigUInt) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .uint256)
    }
    
     static func uint(_ value: UInt8) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .uint8)
    }
    
     static func uint(_ value: UInt16) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .uint16)
    }
    
     static func uint(_ value: UInt32) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .uint32)
    }
    
     static func uint(_ value: UInt64) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .uint64)
    }
    
    // Int
    
     static func int(_ value: BigInt) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .int256)
    }
    
     static func int(_ value: Int8) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .int8)
    }
    
     static func int(_ value: Int16) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .int16)
    }
    
     static func int(_ value: Int32) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .int32)
    }
    
     static func int(_ value: Int64) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .int64)
    }
    
    // Bytes
    
     static func bytes(_ value: Data) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .bytes(length: nil))
    }
    
     static func fixedBytes(_ value: Data) -> SolidityWrappedValue {
        return SolidityWrappedValue(value: value, type: .bytes(length: UInt(value.count)))
    }
    
    // Arrays
    
    // .array([1, 2, 3], elementType: .uint256) -> uint256[]
    // .array([[1,2], [3,4]], elementType: .array(.uint256, length: nil)) -> uint256[][]
     static func array<T: ABIEncodable>(_ value: [T], elementType: SolidityType) -> SolidityWrappedValue {
        let type = SolidityType.array(type: elementType, length: nil)
        return SolidityWrappedValue(value: value, type: type)
    }
    
     static func array<T: ABIEncodable & SolidityTypeRepresentable>(_ value: [T]) -> SolidityWrappedValue {
        return array(value, elementType: T.solidityType)
    }
    
    // .fixedArray([1, 2, 3], elementType: .uint256, length: 3) -> uint256[3]
    // .fixedArray([[1,2], [3,4]], elementType: .array(.uint256, length: nil), length: 2) -> uint256[][2]
     static func fixedArray<T: ABIEncodable>(_ value: [T], elementType: SolidityType, length: UInt) -> SolidityWrappedValue {
        let type = SolidityType.array(type: elementType, length: length)
        return SolidityWrappedValue(value: value, type: type)
    }
    
     static func fixedArray<T: ABIEncodable & SolidityTypeRepresentable>(_ value: [T], length: UInt) -> SolidityWrappedValue {
        return fixedArray(value, elementType: T.solidityType, length: length)
    }
    
     static func fixedArray<T: ABIEncodable & SolidityTypeRepresentable>(_ value: [T]) -> SolidityWrappedValue {
        return fixedArray(value, length: UInt(value.count))
    }
    
    // Array Convenience
    
     static func array<T: ABIEncodable & SolidityTypeRepresentable>(_ value: [[T]]) -> SolidityWrappedValue {
        return array(value, elementType: .array(type: T.solidityType, length: nil))
    }
    
     static func array<T: ABIEncodable & SolidityTypeRepresentable>(_ value: [[[T]]]) -> SolidityWrappedValue {
        return array(value, elementType: .array(type: .array(type: T.solidityType, length: nil), length: nil))
    }
}
