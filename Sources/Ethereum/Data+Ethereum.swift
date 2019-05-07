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
    
    var trimmedHex: String {
        var oldBytes = self.bytes
        var str = "0x"
        var bytes = Array<UInt8>()
        
        var leading = true
        for i in 0 ..< oldBytes.count {
            if leading && oldBytes[i] == 0x00 {
                continue
            }
            leading = false
            bytes.append(oldBytes[i])
        }
        
        if bytes.count > 0 {
            // If there is one leading zero (4 bit) left, this one removes it
            str += String(bytes[0], radix: 16)
            
            for i in 1..<bytes.count {
                str += String(format: "%02x", bytes[i])
            }
        } else {
            str += "0"
        }
        
        return str
    }

    var trimmedLeadingZeros: Data {
        // trim leading zeros
        var from = 0
        while from < count-1 && self[from] == 0x00 {
            from += 1
        }
        return self[from...]
    }
    
    var bigEndianUInt: UInt? {
        guard self.count <= MemoryLayout<UInt>.size else {
            return nil
        }
        var number: UInt = 0
        for i in (0 ..< self.count).reversed() {
            number = number | (UInt(self[self.count - i - 1]) << (i * 8))
        }
        
        return number
    }
}
