//
//  EthereumQuantity.swift
//  Web3
//
//  Created by Koray Koska on 10.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation
import BigInt

public struct Quantity: Hashable, Equatable {

    public let quantity: BigUInt
    
    public init(data: Data) {
        self.init(BigUInt(data))
    }
    
    public init(hex: String) throws {
        try self.init(data: EthData(hex: hex).data)
    }

    public init(_ quantity: BigUInt) {
        self.quantity = quantity
    }

    public var hex: String {
        return data.trimmedHex
    }
    
    public var data: Data {
        return quantity.serialize()
    }
}

extension Quantity: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = UInt64

    public init(integerLiteral value: UInt64) {
        self.init(BigUInt(value))
    }
}

extension Quantity: ValueConvertible {

    public static func string(_ string: String) throws -> Quantity {
        return try self.init(ethereumValue: .string(string))
    }

    public init(ethereumValue: Value) throws {
        guard let str = ethereumValue.string else {
            throw ValueInitializableError.notInitializable
        }

        try self.init(hex: str)
    }

    public func ethereumValue() -> Value {
        return .init(stringLiteral: hex)
    }
}

public extension Value {

    var quantity: Quantity? {
        return try? Quantity(ethereumValue: self)
    }
}
