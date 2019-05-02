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
    
    init(eth hex: String) throws {
        var fixed = hex
        if hex.count % 2 != 0 {
            fixed = hex + "0"
        }
        self.init(hex: fixed)
    }
    
    var ethHex: String {
        var oldBytes = self.bytes
        var bytes = Array<UInt8>()
        
        var leading = true
        for i in 0 ..< oldBytes.count {
            if leading && oldBytes[i] == 0x00 {
                continue
            }
            leading = false
            bytes.append(oldBytes[i])
        }
        
        return "0x" + bytes.toHexString()
    }
}
