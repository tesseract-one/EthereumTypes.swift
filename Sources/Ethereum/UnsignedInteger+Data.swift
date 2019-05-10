//
//  UnsignedInteger+BytesConvertible.swift
//  Web3
//
//  Created by Koray Koska on 06.04.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation
import BigInt


public extension UnsignedInteger {

    /**
     * Bytes are concatenated to make an UnsignedInteger Object (expected to be big endian)
     *
     * [0b1111_1011, 0b0000_1111]
     * =>
     * 0b1111_1011_0000_1111
     *
     * - parameter bytes: The Data to be converted
     *
     */
    init(data: Data) {
        let value: UInt64 = data.withUnsafeBytes { buffer in
            let bytes = buffer.bindMemory(to: UInt8.self)
            // 8 bytes in UInt64, etc. clips overflow
            let prefix = bytes.suffix(MemoryLayout<Self>.size)
            var value: UInt64 = 0
            for byte in prefix {
                value <<= 8 // 1 byte is 8 bits
                value |= UInt64(byte)
            }
            return value
        }

        self.init(value)
    }
    
    /**
     * Bytes are concatenated to make an UnsignedInteger Object (expected to be big endian)
     * Checks that amount of bytes can be represented with the type of UnsignedInteger
     *
     * - parameter bytes: The Data to be converted
     *
    */
    init?(exactly data: Data) {
        guard data.count <= MemoryLayout<Self>.size else {
            return nil
        }
        self.init(data: data)
    }

    /**
     *
     * Convert an UnsignedInteger into its collection of bytes (big endian)
     *
     * 0b1111_1011_0000_1111
     * =>
     * [0b1111_1011, 0b0000_1111]
     * ... etc.
     *
     * - returns: The generated Data.
     *
     */
    var data: Data {
        let byteMask: Self = 0b1111_1111
        let size = MemoryLayout<Self>.size
        var copy = self
        var bytes = Data(capacity: size)
        for _ in 1...size {
            bytes.insert(UInt8(UInt64(copy & byteMask)), at: 0)
            copy /= 256 // >> 8 by Ethereum spec
        }
        return bytes
    }
}


// BigUInt needs it's own implementation, because it's bigger than UInt64.
// It has own data methods so we are simply calling them.
public extension BigUInt {
    
    /**
     * Bytes are concatenated to make an BigUInt Object (expected to be big endian)
     *
     * [0b1111_1011, 0b0000_1111]
     * =>
     * 0b1111_1011_0000_1111
     *
     * - parameter bytes: The Data to be converted
     *
     */
    init(data: Data) {
        self.init(data)
    }
    
    /**
     * Bytes are concatenated to make an BigUInt Object (expected to be big endian)
     *
     * - parameter bytes: The Data to be converted
     *
     */
    init?(exactly data: Data) {
        self.init(data)
    }
    
    /**
     *
     * Convert an BigUInt into its collection of bytes (big endian)
     *
     * 0b1111_1011_0000_1111
     * =>
     * [0b1111_1011, 0b0000_1111]
     * ... etc.
     *
     * - returns: The generated Data.
     *
     */
    var data: Data {
        return serialize()
    }
}
