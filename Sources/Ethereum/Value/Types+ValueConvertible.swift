//
//  Types+EthereumValueConvertible.swift
//  Web3
//
//  Created by Koray Koska on 11.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation

extension Bool: ValueConvertible {

    public init(ethereumValue: Value) throws {
        guard let bool = ethereumValue.bool else {
            throw ValueInitializableError.notInitializable
        }

        self = bool
    }

    public func ethereumValue() -> Value {
        return .bool(self)
    }
}

extension String: ValueConvertible {

    public init(ethereumValue: Value) throws {
        guard let str = ethereumValue.string else {
            throw ValueInitializableError.notInitializable
        }

        self = str
    }

    public func ethereumValue() -> Value {
        return .string(self)
    }
}

extension Int: ValueConvertible {

    public init(ethereumValue: Value) throws {
        guard let int = ethereumValue.int else {
            throw ValueInitializableError.notInitializable
        }

        self = int
    }

    public func ethereumValue() -> Value {
        return .int(self)
    }
}
