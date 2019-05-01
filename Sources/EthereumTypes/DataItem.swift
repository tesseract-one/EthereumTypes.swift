//
//  DataItem.swift
//  EthereumTypes
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

enum DataItem {
    case bytes(Data)
    case array(Array<DataItem>)
    
    enum Error: Swift.Error {
        case inputTooLong
    }
    
    func encode() throws -> Data {
        switch self {
        case .bytes(let b):
            return try encodeBytes(b)
        case .array(let a):
            return try encodeArray(a)
        }
    }
    
    private func encodeArray(_ elements: Array<DataItem>) throws -> Data {
        var bytes = Data()
        for item in elements {
            try bytes.append(contentsOf: item.encode())
        }
        let combinedCount = bytes.count
        
        if combinedCount <= 55 {
            let sign: UInt8 = 0xc0 + UInt8(combinedCount)
            // If the total payload of a list (i.e. the combined length of all its items being RLP encoded)
            // is 0-55 bytes long, the RLP encoding consists of a single byte with value 0xc0 plus
            // the length of the list followed by the concatenation of the RLP encodings of the items.
            bytes.insert(sign, at: 0)
            return bytes
        } else {
            // If the total payload of a list is more than 55 bytes long, the RLP encoding consists of
            // a single byte with value 0xf7 plus the length in bytes of the length of the payload
            // in binary form, followed by the length of the payload, followed by the concatenation of
            // the RLP encodings of the items.
            let length = uintToBytes(UInt(bytes.count)).bytes
            
            let lengthCount = length.count
            guard lengthCount <= 0xff - 0xf7 else {
                throw Error.inputTooLong
            }
            
            let sign: UInt8 = 0xf7 + UInt8(lengthCount)
            
            for i in (0 ..< length.count).reversed() {
                bytes.insert(length[i], at: 0)
            }
            
            bytes.insert(sign, at: 0)
            
            return bytes
        }
    }
    
    private func encodeBytes(_ bytes: Data) throws -> Data {
        var bytes = bytes
        if bytes.count == 1 && bytes[0] >= 0x00 && bytes[0] <= 0x7f {
            // For a single byte whose value is in the [0x00, 0x7f] range, that byte is its own RLP encoding.
            return bytes
        } else if bytes.count <= 55 {
            // bytes.count is less than or equal 55 so casting is safe
            let sign: UInt8 = 0x80 + UInt8(bytes.count)
            
            // If a string is 0-55 bytes long, the RLP encoding consists of a single byte
            // with value 0x80 plus the length of the string followed by the string.
            bytes.insert(sign, at: 0)
            return bytes
        } else {
            // If a string is more than 55 bytes long, the RLP encoding consists of a single byte
            // with value 0xb7 plus the length in bytes of the length of the string in binary form,
            // followed by the length of the string, followed by the string.
            let length = uintToBytes(UInt(bytes.count)).bytes
            
            let lengthCount = length.count
            guard lengthCount <= 0xbf - 0xb7 else {
                // This only really happens if the byte count of the length of the bytes array is
                // greater than or equal 0xbf - 0xb7. This is because 0xbf is the maximum allowed
                // signature byte for this type if rlp encoding.
                throw Error.inputTooLong
            }
            
            let sign: UInt8 = 0xb7 + UInt8(lengthCount)
            
            for i in (0 ..< length.count).reversed() {
                bytes.insert(length[i], at: 0)
            }
            
            bytes.insert(sign, at: 0)
            
            return bytes
        }
    }
    
    // big-endian
    private func uintToBytes(_ int: UInt) -> Data {
        let byteMask: UInt = 0b1111_1111
        let size = MemoryLayout<UInt>.size
        var copy = int
        var bytes: Data = Data()
        for _ in 1...size {
            bytes.insert(UInt8(UInt64(copy & byteMask)), at: 0)
            copy = copy >> 8
        }
        return bytes.trimmedLeadingZeros
    }
}


extension Data {
    var trimmedLeadingZeros: Data {
        // trim leading zeros
        var from = 0
        while from < count-1 && self[from] == 0x00 {
            from += 1
        }
        return self[from...]
    }
}
