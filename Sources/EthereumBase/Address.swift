//
//  Address.swift
//  EthereumBase
//
//  Created by Yehor Popovych on 3/28/19.
//  Copyright © 2019 Tesseract Systems, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import CryptoSwift

public struct Address: Codable, RawRepresentable {
    public typealias RawValue = Data
    
    public let rawValue: Data
    
    // MARK: - Initialization
    /**
     * Initializes this instance of `EthereumAddress` with the given `hex` String.
     *
     * `hex` must be either 40 characters (20 bytes) or 42 characters (with the 0x hex prefix) long.
     *
     * If `eip55` is set to `true`, a checksum check will be done over the given hex string as described
     * in https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md
     *
     * - parameter hex: The ethereum address as a hex string. Case sensitive iff `eip55` is set to true.
     * - parameter eip55: Whether to check the checksum as described in eip 55 or not.
     *
     * - throws: EthereumAddress.Error.addressMalformed if the given hex string doesn't fulfill the conditions described above.
     *           EthereumAddress.Error.checksumWrong iff `eip55` is set to true and the checksum is wrong.
     */
    public init(hex: String, eip55: Bool) throws {
        // Check length
        guard hex.count == 40 || hex.count == 42 else {
            throw Error.addressMalformed
        }
        
        var hex = hex
        
        // Check prefix
        if hex.count == 42 {
            let s = hex.index(hex.startIndex, offsetBy: 0)
            let e = hex.index(hex.startIndex, offsetBy: 2)
            
            guard String(hex[s..<e]) == "0x" else {
                throw Error.addressMalformed
            }
            
            // Remove prefix
            let hexStart = hex.index(hex.startIndex, offsetBy: 2)
            hex = String(hex[hexStart...])
        }
        
        // Check hex
        guard hex.rangeOfCharacter(from: Address.hexadecimals.inverted) == nil else {
            throw Error.addressMalformed
        }
        
        // Create address bytes
        var addressBytes = Data()
        for i in stride(from: 0, to: hex.count, by: 2) {
            let s = hex.index(hex.startIndex, offsetBy: i)
            let e = hex.index(hex.startIndex, offsetBy: i + 2)
            
            guard let b = UInt8(String(hex[s..<e]), radix: 16) else {
                throw Error.addressMalformed
            }
            addressBytes.append(b)
        }
        self.rawValue = addressBytes
        
        // EIP 55 checksum
        // See: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md
        if eip55 {
            let hash = SHA3(variant: .keccak256).calculate(for: Array(hex.lowercased().utf8))
            
            for i in 0..<hex.count {
                let charString = String(hex[hex.index(hex.startIndex, offsetBy: i)])
                if charString.rangeOfCharacter(from: Address.hexadecimalNumbers) != nil {
                    continue
                }
                
                let bytePos = (4 * i) / 8
                let bitPos = (4 * i) % 8
                guard bytePos < hash.count && bitPos < 8 else {
                    throw Error.addressMalformed
                }
                let bit = (hash[bytePos] >> (7 - UInt8(bitPos))) & 0x01
                
                if charString.lowercased() == charString && bit == 1 {
                    throw Error.checksumWrong
                } else if charString.uppercased() == charString && bit == 0 {
                    throw Error.checksumWrong
                }
            }
        }
    }
    
    /**
     * Initializes a new instance of `EthereumAddress` with the given raw Bytes array.
     *
     * `rawAddress` must be exactly 20 bytes long.
     *
     * - parameter rawAddress: The raw address as a byte array.
     *
     * - throws: EthereumAddress.Error.addressMalformed if the rawAddress array is not 20 bytes long.
     */
    public init(rawAddress: Data) throws {
        guard rawAddress.count == 20 else {
            throw Error.addressMalformed
        }
        self.rawValue = rawAddress
    }
    
    public init?(rawValue: Data) {
        do {
            try self.init(rawAddress: rawValue)
        } catch {
            return nil
        }
    }
    
    // MARK: - Convenient functions
    /**
     * Returns this ethereum address as a hex string.
     *
     * Adds the EIP 55 mixed case checksum if `eip55` is set to true.
     *
     * - parameter eip55: Whether to add the mixed case checksum as described in eip 55.
     *
     * - returns: The hex string representing this `EthereumAddress`.
     *            Either lowercased or mixed case (checksumed) depending on the parameter `eip55`.
     */
    public func hex(eip55: Bool) -> String {
        var hex = "0x"
        if !eip55 {
            for b in rawValue {
                hex += String(format: "%02x", b)
            }
        } else {
            var address = ""
            for b in rawValue {
                address += String(format: "%02x", b)
            }
            let hash = SHA3(variant: .keccak256).calculate(for: Array(address.utf8))
            
            for i in 0..<address.count {
                let charString = String(address[address.index(address.startIndex, offsetBy: i)])
                
                if charString.rangeOfCharacter(from: Address.hexadecimalNumbers) != nil {
                    hex += charString
                    continue
                }
                
                let bytePos = (4 * i) / 8
                let bitPos = (4 * i) % 8
                let bit = (hash[bytePos] >> (7 - UInt8(bitPos))) & 0x01
                
                if bit == 1 {
                    hex += charString.uppercased()
                } else {
                    hex += charString.lowercased()
                }
            }
        }
        
        return hex
    }
    
    // MARK: - Errors
    public enum Error: Swift.Error {
        
        case addressMalformed
        case checksumWrong
    }
    
    private static let hexadecimals: CharacterSet = [
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "a", "b", "c", "d", "e", "f", "A", "B", "C", "D", "E", "F"
    ]
    
    private static let hexadecimalNumbers: CharacterSet = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
}
