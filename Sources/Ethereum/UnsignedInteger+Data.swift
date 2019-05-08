//
//  UnsignedInteger+BytesConvertible.swift
//  Web3
//
//  Created by Koray Koska on 06.04.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation


extension UnsignedInteger {

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
    public init(data: Data) {
        // 8 bytes in UInt64, etc. clips overflow
        let prefix = data.suffix(MemoryLayout<Self>.size)
        var value: UInt64 = 0
        prefix.forEach { byte in
            value <<= 8 // 1 byte is 8 bits
            value |= UInt64(byte)
        }

        self.init(value)
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
    public var data: Data {
        let byteMask: Self = 0b1111_1111
        let size = MemoryLayout<Self>.size
        var copy = self
        var bytes = Data()
        (1...size).forEach { _ in
            bytes.insert(UInt8(UInt64(copy & byteMask)), at: 0)
            copy /= 256 // >> 8 by Ethereum spec
        }
        return bytes
    }
}
