//
//  EthereumValueConvertible.swift
//  Web3
//
//  Created by Koray Koska on 10.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation

/**
 * Objects which can be converted to `EthereumValue` can implement this.
 */
public protocol ValueRepresentable: Encodable {

    /**
     * Converts `self` to `EthereumValue`.
     *
     * - returns: The generated `EthereumValue`.
     */
    func ethereumValue() -> Value
}

/**
 * Objects which can be initialized with `EthereumValue`'s can implement this.
 */
public protocol ValueInitializable: Decodable {

    /**
     * Initializes `self` with the given `EthereumValue` if possible. Throws otherwise.
     *
     * - parameter ethereumValue: The `EthereumValue` to be converted to `self`.
     */
    init(ethereumValue: Value) throws
}

/**
 * Objects which are both representable and initializable by and with `EthereumValue`'s.
 */
public typealias ValueConvertible = ValueRepresentable & ValueInitializable

extension ValueInitializable {

    public init(ethereumValue: ValueRepresentable) throws {
        let e = ethereumValue.ethereumValue()
        try self.init(ethereumValue: e)
    }
}

// MARK: - Default Codable

extension ValueRepresentable {

    public func encode(to encoder: Encoder) throws {
        try ethereumValue().encode(to: encoder)
    }
}

extension ValueInitializable {

    public init(from decoder: Decoder) throws {
        try self.init(ethereumValue: Value(from: decoder))
    }
}

// MARK: - Errors

public enum ValueRepresentableError: Swift.Error {

    case notRepresentable
}

public enum ValueInitializableError: Swift.Error {

    case notInitializable
}
