//
//  Transaction.swift
//  EthereumBase
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

@_exported import BigInt


public struct Transaction {
    /// The number of transactions made prior to this one
    public var nonce: BigUInt
    
    /// Gas price provided Wei
    public var gasPrice: BigUInt
    
    /// Gas limit provided
    public var gas: BigUInt
    
    // Address of the sender
    public var from: Address
    
    /// Address of the receiver
    public var to: Address?
    
    /// Value to transfer provided in Wei
    public var value: BigUInt
    
    /// Input data for this transaction
    public var data: Data
    
    public init(
        nonce: BigUInt, gasPrice: BigUInt, gas: BigUInt,
        from: Address, to: Address? = nil, value: BigUInt,
        data: Data? = nil
    ) {
        self.nonce = nonce
        self.gasPrice = gasPrice
        self.gas = gas
        self.from = from
        self.to = to
        self.value = value
        self.data = data ?? Data()
    }
    
    public func rawData(chainId: BigUInt) throws -> Data {
        let item: DataItem = .array([
            .bytes(nonce.serialize().trimmedLeadingZeros),
            .bytes(gasPrice.serialize().trimmedLeadingZeros),
            .bytes(gas.serialize().trimmedLeadingZeros),
            .bytes(to?.rawValue ?? Data()),
            .bytes(value.serialize().trimmedLeadingZeros),
            .bytes(data),
            .bytes(chainId.serialize().trimmedLeadingZeros),
            .bytes(BigUInt(0).serialize().trimmedLeadingZeros),
            .bytes(BigUInt(0).serialize().trimmedLeadingZeros)
        ])
        return try item.encode()
    }
}
