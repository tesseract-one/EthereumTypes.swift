//
//  Transaction.swift
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

@_exported import BigInt


public struct Transaction: Codable, Hashable, Equatable {
    
    public enum Error: Swift.Error {
        case transactionInvalid
    }
    
    /// The number of transactions made prior to this one
    public var nonce: Quantity?
    
    /// Gas price provided Wei
    public var gasPrice: Quantity?
    
    /// Gas limit provided
    public var gas: Quantity?
    
    // Address of the sender
    public var from: Address?
    
    /// Address of the receiver
    public var to: Address?
    
    /// Value to transfer provided in Wei
    public var value: Quantity
    
    /// Input data for this transaction
    public var data: EthData?
    
    public init(
        nonce: Quantity? = nil, gasPrice: Quantity? = nil, gas: Quantity? = nil,
        from: Address? = nil, to: Address? = nil, value: Quantity = 0,
        data: EthData? = nil
    ) throws {
        guard (data != nil && data!.data.count > 0) || to != nil else {
            throw Transaction.Error.transactionInvalid
        }
        
        self.nonce = nonce
        self.gasPrice = gasPrice
        self.gas = gas
        self.from = from
        self.to = to
        self.value = value
        self.data = data
    }
    
    public func rlp(chainId: Quantity = 0) throws -> RLPItem {
        // These values are required for signing
        guard let nonce = nonce, let gasPrice = gasPrice, let gasLimit = gas else {
            throw Error.transactionInvalid
        }
        let rlp = RLPItem(
            nonce: nonce,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            to: to,
            value: value,
            data: data,
            v: chainId,
            r: 0,
            s: 0
        )
        return rlp
    }
}

extension RLPItem {
    /**
     * Create an RLPItem representing a transaction. The RLPItem must be an array of 9 items in the proper order.
     *
     * - parameter nonce: The nonce of this transaction.
     * - parameter gasPrice: The gas price for this transaction in wei.
     * - parameter gasLimit: The gas limit for this transaction.
     * - parameter to: The address of the receiver.
     * - parameter value: The value to be sent by this transaction in wei.
     * - parameter data: Input data for this transaction.
     * - parameter v: EC signature parameter v, or a EIP155 chain id for an unsigned transaction.
     * - parameter r: EC signature parameter r.
     * - parameter s: EC recovery ID.
     */
    public init(
        nonce: Quantity,
        gasPrice: Quantity,
        gasLimit: Quantity,
        to: Address?,
        value: Quantity,
        data: EthData?,
        v: Quantity,
        r: Quantity,
        s: Quantity
    ) {
        self = .array(
            .bigUInt(nonce.quantity),
            .bigUInt(gasPrice.quantity),
            .bigUInt(gasLimit.quantity),
            .bytes(to?.rawValue ?? Data()),
            .bigUInt(value.quantity),
            .bytes(data?.data ?? Data()),
            .bigUInt(v.quantity),
            .bigUInt(r.quantity),
            .bigUInt(s.quantity)
        )
    }
    
}
