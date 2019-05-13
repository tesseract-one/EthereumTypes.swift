//
//  Data+Ethereum.swift
//  EthereumTypes
//
//  Created by Yehor Popovych on 3/14/19.
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

public extension Data {
    /**
     * Creates Data object from trimmed leading zeroes hex representation (big-endian)
     * Can wotrk with '0x' prefixed and unprefixed strings
     *
     * - parameter trimmedHex: The hex String to be converted
     *
     */
    init(trimmedHex: String) {
        var fixed = trimmedHex
        if fixed.count >= 2 && fixed.starts(with: "0x") {
            let index = fixed.index(fixed.startIndex, offsetBy: 2)
            fixed = String(fixed[index...])
        }
        if fixed.count % 2 != 0 {
            fixed = "0" + fixed
        }
        self.init(hex: fixed)
    }
    
    /**
     * Returns hex represenation with trimmed leading zeroes (big-endian)
     * Prefixed with '0x'
     */
    var trimmedHex: String {
        let trimmed = trimmedLeadingZeros
        if trimmed.count > 0 {
            // If there is one leading zero (4 bit) left, this one removes it
            return "0x" + String(trimmed[0], radix: 16) + trimmed[1...].toHexString()
        } else {
            return "0x0"
        }
    }

    /**
     * Returns Data object with trimmed leading zeroes (big-endian)
     */
    var trimmedLeadingZeros: Data {
        return withUnsafeBytes { buffer in
            let bytes = buffer.bindMemory(to: UInt8.self)
            var from = 0
            // ignore leading zeros
            while from < bytes.count-1 && bytes[from] == 0x00 {
                from += 1
            }
            // Copy bytes
            return Data(bytes[from...])
        }
    }
}
