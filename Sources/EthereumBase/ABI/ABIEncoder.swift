//
//  ABIEncoder.swift
//  Web3
//
//  Created by Josh Pyles on 5/21/18.
//

import Foundation
import BigInt

class ABIEncoder {
    enum Error: Swift.Error {
        case couldNotEncode(type: SolidityType, value: Any)
    }
    
    struct Segment {
        let type: SolidityType
        let encodedValue: String
        
        init(type: SolidityType, value: String) {
            self.type = type
            self.encodedValue = value
        }
        
        /// Byte count of static value
        var staticLength: Int {
            if !type.isDynamic {
                // if we have a static value, return the length / 2 (assuming hex string)
                return encodedValue.count / 2
            }
            // otherwise, this will be an offset value, padded to 32 bytes
            return 32
        }
    }
    
    /// Encode pairs of values and expected types to Solidity ABI compatible string
    class func encode(_ values: [SolidityWrappedValue]) throws -> String {
        // map segments
        let segments = try values.map { wrapped -> Segment in
            // encode value portion
            let encodedValue = try encode(wrapped.value, to: wrapped.type)
            return Segment(type: wrapped.type, value: encodedValue)
        }
        // calculate start of dynamic portion in bytes (combined length of all static parts)
        let dynamicOffsetStart = segments.map { $0.staticLength }.reduce(0, +)
        // reduce to static string and dynamic string
        let (staticValues, dynamicValues) = segments.reduce(("", ""), { result, segment in
            var (staticParts, dynamicParts) = result
            if !segment.type.isDynamic {
                staticParts += segment.encodedValue
            } else {
                // static portion for dynamic value represents offset in bytes
                // offset is start of dynamic segment + length of current dynamic portion (in bytes)
                let offset = dynamicOffsetStart + (result.1.count / 2)
                staticParts += String(offset, radix: 16).paddingLeft(toLength: 64, withPad: "0")
                dynamicParts += segment.encodedValue
            }
            return (staticParts, dynamicParts)
        })
        // combine as single string (static parts, then dynamic parts)
        return staticValues + dynamicValues
    }
    
    /// Encode with values inline
    class func encode(_ values: SolidityWrappedValue...) throws -> String {
        return try encode(values)
    }
    
    /// Encode a single wrapped value
    class func encode(_ wrapped: SolidityWrappedValue) throws -> String {
        return try encode([wrapped])
    }
    
    /// Encode a single value to a type
    class func encode(_ value: ABIEncodable, to type: SolidityType) throws -> String {
        if let encoded = value.abiEncode(dynamic: type.isDynamic) {
            return encoded
        }
        throw Error.couldNotEncode(type: type, value: value)
    }
}

extension String {
    func substr(_ offset: Int,  _ length: Int) -> String? {
        guard offset + length <= self.count else { return nil }
        let start = index(startIndex, offsetBy: offset)
        let end = index(start, offsetBy: length)
        return String(self[start..<end])
    }
    
    func paddingLeft(toLength length: Int, withPad character: Character) -> String {
        if self.count < length {
            return String(repeatElement(character, count: length - self.count)) + self
        } else {
            return String(self.prefix(length))
        }
    }
    
    func paddingLeft(toMultipleOf base: Int, withPad character: Character) -> String {
        // round up to the nearest multiple of base
        let newLength = Int(ceil(Double(count) / Double(base))) * base
        return self.paddingLeft(toLength: newLength, withPad: character)
    }
    
    func padding(toMultipleOf base: Int, withPad character: Character) -> String {
        // round up to the nearest multiple of base
        let newLength = Int(ceil(Double(count) / Double(base))) * base
        return self.padding(toLength: newLength, withPad: String(character), startingAt: 0)
    }
    
    func binaryToHex() -> String {
        var binaryString = self
        if binaryString.count % 8 > 0 {
            binaryString = "0" + binaryString
        }
        let bytesCount = binaryString.count / 8
        return (0..<bytesCount).compactMap({ i in
            let offset = i * 8
            if let str = binaryString.substr(offset, 8), let int = UInt8(str, radix: 2) {
                return String(format: "%02x", int)
            }
            return nil
        }).joined()
    }
}
