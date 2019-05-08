//
//  EthereumData.swift
//  Web3
//
//  Created by Koray Koska on 11.02.18.
//  Copyright © 2018 Boilertalk. All rights reserved.
//

import Foundation

public struct EthData: Hashable, Equatable {
    public let data: Data

    public init(_ data: Data) {
        self.data = data
    }
    
    public init(hex: String) throws {
        if hex.count == 0 || hex == "0x" {
            self.init(Data())
        } else {
            let data = Data(hex: hex)
            guard data.count > 0 else { throw Error.hexIsMalformed }
            self.init(data)
        }
    }

    public var hex: String {
        return "0x" + data.toHexString()
    }
    
    public enum Error: Swift.Error {
        case hexIsMalformed
    }
}

extension EthData: ValueConvertible {
    
    public static func string(_ string: String) throws -> EthData {
        return try self.init(ethereumValue: .string(string))
    }
    
    public init(ethereumValue: Value) throws {
        guard let str = ethereumValue.string else {
            throw ValueInitializableError.notInitializable
        }
        
        try self.init(hex: str)
    }
    
    public func ethereumValue() -> Value {
        return Value(stringLiteral: hex)
    }
}

public extension Value {
    
    var data: EthData? {
        return try? EthData(ethereumValue: self)
    }
}
