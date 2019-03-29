//
//  SignProvider.swift
//  EthereumBase
//
//  Created by Yehor Popovych on 3/2/19.
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

public let ETHEREUM_SLIP44_COIN_ID: UInt32 = 0x8000003c

public enum SignProviderError: Error {
    case accountDoesNotExist(Address)
    case emptyAccount
    case mandatoryFieldMissing(String)
    case cancelled
    case nonIntNetworkVersion(String)
    case internalError(Error)
}

public protocol SignProvider {
    
    typealias Response<Type> = (Result<Type, SignProviderError>) -> Void
    
    func eth_accounts(networkId: UInt64, response: @escaping Response<Array<Address>>)
    
    func eth_signTx(
        tx: Transaction, networkId: UInt64, chainId: UInt64,
        response: @escaping Response<Data>
    )
    
    func eth_signData(
        account: Address, data: Data, networkId: UInt64,
        response: @escaping Response<Data>
    )
    
    func eth_signTypedData(
        account: Address, data: TypedData, networkId: UInt64,
        response: @escaping Response<Data>
    )
}
