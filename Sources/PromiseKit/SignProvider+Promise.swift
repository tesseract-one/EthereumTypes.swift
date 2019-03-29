//
//  SignProvider+Promise.swift
//  EthereumBase
//
//  Created by Yehor Popovych on 3/29/19.
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
import PromiseKit

public extension SignProvider {
    func eth_accounts(networkId: UInt64) -> Promise<Array<Address>> {
        return Promise { resolver in
            self.eth_accounts(networkId: networkId, response: resolver.fromResult)
        }
    }
    
    func eth_signTx(
        tx: Transaction, networkId: UInt64, chainId: UInt64
    ) -> Promise<Data> {
        return Promise { resolver in
            self.eth_signTx(tx: tx, networkId: networkId, chainId: chainId, response: resolver.fromResult)
        }
    }
    
    func eth_signData(
        account: Address, data: Data, networkId: UInt64
    ) -> Promise<Data> {
        return Promise { resolver in
            self.eth_signData(
                account: account, data: data, networkId: networkId,
                response: resolver.fromResult
            )
        }
    }
    
    func eth_signTypedData(
        account: Address, data: TypedData, networkId: UInt64
    ) -> Promise<Data> {
        return Promise { resolver in
            self.eth_signTypedData(
                account: account, data: data, networkId: networkId,
                response: resolver.fromResult
            )
        }
    }
}

private extension Resolver {
    func fromResult<Err: Error>(_ result: Swift.Result<T, Err>) {
        switch result {
        case .failure(let err): reject(err)
        case .success(let val): fulfill(val)
        }
    }
}
