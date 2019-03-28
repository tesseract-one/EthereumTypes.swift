//
//  ABIRepresentable.swift
//  AppAuth
//
//  Created by Josh Pyles on 5/22/18.
//

import Foundation
import BigInt

/// A type that is always represented as a single SolidityType
protocol SolidityTypeRepresentable {
    static var solidityType: SolidityType { get }
}

/// A type that can be converted to a Solidity value
protocol ABIEncodable {
    /// Encode to hex string
    ///
    /// - Parameter dynamic: Hopefully temporary workaround until dynamic conditional conformance works
    /// - Returns: Solidity ABI encoded hex string
    func abiEncode(dynamic: Bool) -> String?
}
// MARK: - Encoding

extension FixedWidthInteger where Self: UnsignedInteger {
     func abiEncode(dynamic: Bool) -> String? {
        return String(self, radix: 16).paddingLeft(toLength: 64, withPad: "0")
    }
    
    static var solidityType: SolidityType {
        return SolidityType.type(.uint(bits: UInt16(bitWidth)))
    }
}

extension FixedWidthInteger where Self: SignedInteger {
    /// Get positive value that would represent this number in twos-complement encoded binary
     var twosComplementRepresentation: Self {
        if self < 0 {
            return abs(Self.min - self)
        }
        return self
    }
    
     func abiEncode(dynamic: Bool) -> String? {
        // for negative signed integers
        if self < 0 {
            // get twos representation
            let twosSelf = twosComplementRepresentation
            // encode value bits
            let binaryString = String(twosSelf, radix: 2)
            // add sign bit
            let paddedBinaryString = "1" + binaryString
            // encode to hex
            let hexValue = paddedBinaryString.binaryToHex()
            // pad with 'f' for negative numbers
            return hexValue.paddingLeft(toLength: 64, withPad: "f")
        }
        // can encode to hex directly if positive
        return String(self, radix: 16).paddingLeft(toLength: 64, withPad: "0")
    }
    
    static var solidityType: SolidityType {
        return SolidityType.type(.int(bits: UInt16(bitWidth)))
    }
}

extension BigInt: ABIEncodable {
     func abiEncode(dynamic: Bool) -> String? {
        if self < 0 {
            // BigInt doesn't have a 'max' or 'min', assume 256-bit.
            let twosSelf = (BigInt(2).power(255)) - abs(self)
            let binaryString = String(twosSelf, radix: 2)
            let paddedBinaryString = "1" + binaryString
            let hexValue = paddedBinaryString.binaryToHex()
            return hexValue.paddingLeft(toLength: 64, withPad: "f")
        }
        return String(self, radix: 16).paddingLeft(toLength: 64, withPad: "0")
    }
}

extension BigInt: SolidityTypeRepresentable {
     static var solidityType: SolidityType {
        return .int256
    }
}

extension BigUInt: ABIEncodable {
     func abiEncode(dynamic: Bool) -> String? {
        return String(self, radix: 16).paddingLeft(toLength: 64, withPad: "0")
    }
}

extension BigUInt: SolidityTypeRepresentable {
     static var solidityType: SolidityType {
        return .uint256
    }
}

// Boolean

extension Bool: ABIEncodable {
     func abiEncode(dynamic: Bool) -> String? {
        if self {
            return "1".paddingLeft(toLength: 64, withPad: "0")
        }
        return "0".paddingLeft(toLength: 64, withPad: "0")
    }
}

extension Bool: SolidityTypeRepresentable {
    static var solidityType: SolidityType {
        return .bool
    }
}

// String

extension String: ABIEncodable {
     func abiEncode(dynamic: Bool) -> String? {
        // UTF-8 encoded bytes, padded right to multiple of 32 bytes
        return Data(self.utf8).abiEncodeDynamic()
    }
}

extension String: SolidityTypeRepresentable {
     static var solidityType: SolidityType {
        return .string
    }
}

// Array

extension Array: ABIEncodable where Element: ABIEncodable {
     func abiEncode(dynamic: Bool) -> String? {
        if dynamic {
            return abiEncodeDynamic()
        }
        // values encoded, joined with no separator
        return self.compactMap { $0.abiEncode(dynamic: false) }.joined()
    }
    
     func abiEncodeDynamic() -> String? {
        // get values
        let values = self.compactMap { value -> String? in
            return value.abiEncode(dynamic: true)
        }
        // number of elements in the array, padded left
        let length = String(values.count, radix: 16).paddingLeft(toLength: 64, withPad: "0")
        // values, joined with no separator
        return length + values.joined()
    }
}

// Bytes

extension Data: ABIEncodable {
     func abiEncode(dynamic: Bool) -> String? {
        if dynamic {
            return abiEncodeDynamic()
        }
        // each byte, padded right
        return map { String(format: "%02x", $0) }.joined().padding(toMultipleOf: 64, withPad: "0")
    }
    
     func abiEncodeDynamic() -> String? {
        // number of bytes
        let length = String(self.count, radix: 16).paddingLeft(toLength: 64, withPad: "0")
        // each bytes, padded right
        let value = map { String(format: "%02x", $0) }.joined().padding(toMultipleOf: 64, withPad: "0")
        return length + value
    }
}

// Address

extension Address: ABIEncodable {
     func abiEncode(dynamic: Bool) -> String? {
        let hexString = hex(eip55: false).replacingOccurrences(of: "0x", with: "")
        return hexString.paddingLeft(toLength: 64, withPad: "0")
    }
}

extension Address: SolidityTypeRepresentable {
     static var solidityType: SolidityType {
        return .address
    }
}


// MARK: - Explicit protocol conformance

extension Int: ABIEncodable, SolidityTypeRepresentable {}
extension Int8: ABIEncodable, SolidityTypeRepresentable {}
extension Int16: ABIEncodable, SolidityTypeRepresentable {}
extension Int32: ABIEncodable, SolidityTypeRepresentable {}
extension Int64: ABIEncodable, SolidityTypeRepresentable {}

extension UInt: ABIEncodable, SolidityTypeRepresentable {}
extension UInt8: ABIEncodable, SolidityTypeRepresentable {}
extension UInt16: ABIEncodable, SolidityTypeRepresentable {}
extension UInt32: ABIEncodable, SolidityTypeRepresentable {}
extension UInt64: ABIEncodable, SolidityTypeRepresentable {}
