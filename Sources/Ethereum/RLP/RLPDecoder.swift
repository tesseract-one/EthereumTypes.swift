//
//  RLPDecoder.swift
//  Web3
//
//  Created by Koray Koska on 03.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation

/**
 * The default RLP Decoder which takes rlp encoded `Bytes` and creates their representing `RLPItem`
 * as documented on Github:
 *
 * https://github.com/ethereum/wiki/wiki/RLP
 */
open class RLPDecoder {

    // MARK: - Initialization

    /**
     * Initializes a new instance of `RLPDecoder`. Currently there are no options you can pass
     * to the initializer. This may change in future releases.
     */
    public init() {
    }

    // MARK: - Decoding

    /**
     * Decodes the given rlp encoded `Byte` array and returns a new instance of `RLPItem`
     * representing the given rlp.
     *
     * - parameter rlp: The rlp encoded `Byte` array.
     *
     * - returns: A new instance of `RLPItem` which represents the given rlp encoded `Byte` array.
     */
    open func decode(_ rlp: Data) throws -> RLPItem {
        return try rlp.withUnsafeBytes { buffer in
            return try self.decode(rlp: buffer.bindMemory(to: UInt8.self))
        }
    }

    // MARK: - Errors

    public enum Error: Swift.Error {

        case inputEmpty
        case inputMalformed
        case inputTooLong

        case lengthPrefixMalformed
    }
    
    // MARK: - Helper methods
    
    private func decode(rlp: UnsafeBufferPointer<UInt8>) throws -> RLPItem {
        guard rlp.count > 0 else {
            throw Error.inputEmpty
        }
        
        let sign = rlp[0]
        
        if sign >= 0x00 && sign <= 0x7f {
            guard rlp.count == 1 else {
                throw Error.inputMalformed
            }
            return .bytes(sign)
        } else if sign >= 0x80 && sign <= 0xb7 {
            let count = sign - 0x80
            guard rlp.count == count + 1 else {
                throw Error.inputMalformed
            }
            let bytes = rlp[1..<rlp.count]
            return .bytes(Data(bytes))
        } else if sign >= 0xb8 && sign <= 0xbf {
            return try decodeLongBytes(sign: sign, rlp: rlp)
        } else if sign >= 0xc0 && sign <= 0xf7 {
            return try decodeShortArray(sign: sign, rlp: rlp)
        } else if sign >= 0xf8 && sign <= 0xff {
            return try decodeLongArray(sign: sign, rlp: rlp)
        } else {
            throw Error.lengthPrefixMalformed
        }
    }

    private func decodeLongBytes(sign: UInt8, rlp: UnsafeBufferPointer<UInt8>) throws -> RLPItem {
        let byteCount = sign - 0xb7
        guard byteCount <= 8 else {
            throw Error.inputTooLong
        }

        let stringCount = try getCount(rlp: rlp)

        let rlpCount = stringCount + Int(byteCount) + 1
        guard rlp.count == rlpCount else {
            throw Error.inputMalformed
        }

        let bytes = rlp[(Int(byteCount) + 1) ..< Int(rlpCount)]
        return .bytes(Data(bytes))
    }

    private func decodeShortArray(sign: UInt8, rlp: UnsafeBufferPointer<UInt8>) throws -> RLPItem {
        let totalCount = sign - 0xc0
        guard rlp.count == totalCount + 1 else {
            throw Error.inputMalformed
        }
        if totalCount == 0 {
            return []
        }
        var items = [RLPItem]()

        var pointer = 1
        while pointer < rlp.count {
            let start = UnsafeBufferPointer<UInt8>(rebasing: rlp[pointer...])
            let count = try getCount(rlp: start)

            guard rlp.count >= (pointer + count + 1) else {
                throw Error.inputMalformed
            }

            let itemRLP = UnsafeBufferPointer<UInt8>(rebasing: rlp[pointer..<(pointer + count + 1)])
            try items.append(decode(rlp: itemRLP))

            pointer += (count + 1)
        }

        return .array(items)
    }

    private func decodeLongArray(sign: UInt8, rlp: UnsafeBufferPointer<UInt8>) throws -> RLPItem {
        let byteCount = sign - 0xf7
        guard byteCount <= 8 else {
            throw Error.inputTooLong
        }

        let totalCount = try getCount(rlp: rlp)

        let rlpCount = totalCount + Int(byteCount) + 1
        guard rlp.count == rlpCount else {
            throw Error.inputMalformed
        }
        var items = [RLPItem]()

        // We start after the length defining bytes (and the first byte)
        var pointer = Int(byteCount) + 1
        while pointer < rlp.count {
            let start = UnsafeBufferPointer<UInt8>(rebasing: rlp[pointer...])
            let count = try getCount(rlp: start) + Int(getLengthByteCount(sign: rlp[pointer]))

            guard rlp.count >= (pointer + count + 1) else {
                throw Error.inputMalformed
            }

            let itemRLP = UnsafeBufferPointer<UInt8>(rebasing: rlp[pointer..<(pointer + count + 1)])
            try items.append(decode(rlp: itemRLP))

            pointer += (count + 1)
        }

        return .array(items)
    }

    /**
     * Returns the length of the given rlp as defined in its signature
     * (first byte plus optional length bytes). Excludes the sign byte (the first byte)
     * and the optional length bytes.
     *
     * - parameter rlp: The rlp to analyze.
     *
     * - returns: The length of the given rlp as defined in its signature.
     */
    private func getCount(rlp: UnsafeBufferPointer<UInt8>) throws -> Int {
        guard rlp.count > 0 else {
            throw Error.inputMalformed
        }
        let sign = rlp[0]
        let count: UInt
        if sign >= 0x00 && sign <= 0x7f {
            count = 0
        } else if sign >= 0x80 && sign <= 0xb7 {
            count = UInt(sign) - UInt(0x80)
        } else if sign >= 0xb8 && sign <= 0xbf {
            let byteCount = sign - 0xb7
            guard rlp.count >= (Int(byteCount) + 1) else {
                throw Error.inputMalformed
            }
            guard let c = UInt(exactly: Data(rlp[1..<(Int(byteCount) + 1)])) else {
                throw Error.inputTooLong
            }
            count = c
        } else if sign >= 0xc0 && sign <= 0xf7 {
            count = UInt(sign) - UInt(0xc0)
        } else if sign >= 0xf8 && sign <= 0xff {
            let byteCount = sign - 0xf7
            guard rlp.count >= (Int(byteCount) + 1) else {
                throw Error.inputMalformed
            }
            guard let c = UInt(exactly: Data(rlp[1..<(Int(byteCount) + 1)])) else {
                throw Error.inputTooLong
            }
            count = c
        } else {
            throw Error.lengthPrefixMalformed
        }

        guard count <= Int.max else {
            throw Error.inputTooLong
        }

        return Int(count)
    }

    /**
     * Returns the number of bytes for the length signature of an rlp encoded item.
     *
     * Returns 0 if the sign includes the length of the rlp item. (<= 55 bytes).
     *
     * - parameter sign: The sign (first byte) of an rlp encoded item.
     *
     * - returns: The number of bytes for the length signature as defined in the given sign.
     */
    private func getLengthByteCount(sign: UInt8) -> UInt8 {
        var byteCount: UInt8 = 0
        if sign >= 0xb8 && sign <= 0xbf {
            byteCount = sign - 0xb7
        } else if sign >= 0xf8 && sign <= 0xff {
            byteCount = sign - 0xf7
        }

        return byteCount
    }
}
