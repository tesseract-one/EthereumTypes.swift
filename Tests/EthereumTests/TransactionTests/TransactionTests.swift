//
//  TransactionTests.swift
//  Web3_Tests
//
//  Created by Koray Koska on 11.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import XCTest

@testable import Ethereum

class TransactionTests: XCTestCase {

    func testRlpEncoding() {
        let to = try? Address(hex: "0xf5745ddac99ee7b70518a9035c00cfd63c490b1d")
        XCTAssertNotNil(to, "should produce the expected rlp encoding")
        let tx1 = try? Transaction(nonce: 0, gasPrice: Quantity(21 * BigUInt(10).power(9)), gas: 21000, to: to, value: Quantity(BigUInt(10).power(18)))
        XCTAssertNotNil(tx1, "should produce the expected rlp encoding")
        guard let transaction1 = tx1 else { return }
        XCTAssertNotNil(tx1, "should produce the expected rlp encoding")
        let expectedTransaction1 = "ed808504e3b2920082520894f5745ddac99ee7b70518a9035c00cfd63c490b1d880de0b6b3a76400008081808080"
        XCTAssertEqual(try? RLPEncoder().encode(transaction1.rlp(chainId: 128)).toHexString(), expectedTransaction1, "should produce the expected rlp encoding")
        
        let tx2 = try? Transaction(nonce: 0, gasPrice: Quantity(21 * BigUInt(10).power(9)), gas: 21000, data: EthData(Data([0x1, 0x2, 0x3])))
        guard let transaction2 = tx2 else { return }
        XCTAssertNotNil(tx2, "should produce the expected rlp encoding")
        let expectedTransaction2 = "d3808504e3b29200825208808083010203808080"
        XCTAssertEqual(try? RLPEncoder().encode(transaction2.rlp()).toHexString(), expectedTransaction2, "should produce the expected rlp encoding")
        
        XCTAssertThrowsError(try Transaction(nonce: 0, gasPrice: Quantity(21 * BigUInt(10).power(9)), gas: 21000)) { err in
            XCTAssertEqual(err as! Transaction.Error, Transaction.Error.transactionInvalid, "should be invalid rlp encoding")
        }
        XCTAssertThrowsError(try Transaction(gasPrice: Quantity(21 * BigUInt(10).power(9)), gas: 21000, to: to).rlp()) { err in
            XCTAssertEqual(err as! Transaction.Error, Transaction.Error.transactionInvalid, "should be invalid rlp encoding")
        }
        XCTAssertThrowsError(try Transaction(nonce: 0, gas: 21000, to: to).rlp()) { err in
            XCTAssertEqual(err as! Transaction.Error, Transaction.Error.transactionInvalid, "should be invalid rlp encoding")
        }
        XCTAssertThrowsError(try Transaction(nonce: 0, gasPrice: Quantity(21 * BigUInt(10).power(9)), to: to).rlp()) { err in
            XCTAssertEqual(err as! Transaction.Error, Transaction.Error.transactionInvalid, "should be invalid rlp encoding")
        }
    }
}
