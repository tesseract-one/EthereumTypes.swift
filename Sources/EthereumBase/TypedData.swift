//
//  TypedData.swift
//  EthereumBase
//
//  Created by Yehor Popovych on 3/18/19.
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
import BigInt

public struct TypedData: Codable {
    
    public struct _Type: Codable {
        public let name: String
        public let type: String
        
        public init(name: String, type: String) {
            self.name = name
            self.type = type
        }
    }
    
    public struct Domain: Codable {
        public let name: String
        public let version: String
        public let chainId: Int
        public let verifyingContract: Address
        
        public init(name: String, version: String, chainId: Int, verifyingContract: Address) {
            self.name = name
            self.version = version
            self.chainId = chainId
            self.verifyingContract = verifyingContract
        }
    }
    
    public enum Error: Swift.Error {
        case unknownType(String)
        case expectedObject(String, SerializableValue)
        case emptyValue(String, _Type)
        case cantEncodeValue(String, SerializableValue)
    }
    
    public let types: Dictionary<String, Array<_Type>>
    public let primaryType: String
    public let domain: Domain
    public let message: Dictionary<String, SerializableValue>
    
    public init(
        primaryType: String,
        types: Dictionary<String, Array<_Type>>,
        domain: Domain,
        message: Dictionary<String, SerializableValueEncodable>
    ) {
        self.primaryType = primaryType
        self.domain = domain
        self.types = types
        self.message = SerializableValue(message).object! // It's 100% object
    }
}

extension TypedData {
    public func signableMessageData() throws -> Data {
        var data = Data([0x19, 0x01])
        try data.append(encodeData(data: domain.serialized, type: "EIP712Domain").sha3(.keccak256))
        try data.append(encodeData(data: .object(message), type: primaryType).sha3(.keccak256))
        return data.sha3(.keccak256)
    }
    
    private func encodeType(type: String) throws -> Data {
        guard let fields = types[type] else { throw Error.unknownType(type) }
        var deps = dependencyList(type: type)
        deps.remove(type)
        let depsArr = [type] + deps.sorted()
        return depsArr.map { type in
            let parameters = fields.map{"\($0.type) \($0.name)"}.joined(separator: ",")
            return "\(type)(\(parameters))"
        }.joined().data(using: .utf8)!
    }
    
    private func dependencyList(type: String, parents: Set<String> = Set()) -> Set<String> {
        guard !parents.contains(type), let subtypes = types[type] else {
            return parents
        }
        var dependencies = parents
        dependencies.insert(type)
        for type in subtypes {
            for dependency in dependencyList(type: type.type, parents: dependencies) {
                dependencies.insert(dependency)
            }
        }
        return dependencies
    }
    
    private func encodeData(data: SerializableValue, type: String) throws -> Data {
        var encodedValues: [SolidityWrappedValue] = []
        
        encodedValues.append(
            SolidityWrappedValue(
                value: try encodeType(type: type).sha3(.keccak256),
                type: .bytes(length: 32)
            )
        )
        
        if let fields = types[type] {
            guard case .object(let object) = data else { throw Error.expectedObject(type, data) }
            for field in fields {
                if types[field.type] != nil {
                    guard let value = object[field.name] else { throw Error.emptyValue(type, field) }
                    let nestEncoded = try encodeData(data: value, type: field.type)
                    let abiValue = SolidityWrappedValue(
                        value: nestEncoded.sha3(.keccak256),
                        type: .bytes(length: 32)
                    )
                    encodedValues.append(abiValue)
                } else {
                    guard let value = object[field.name] else { throw Error.emptyValue(type, field) }
                    let abiValue = try convertSimpleValue(value: value, type: field.type)
                    encodedValues.append(abiValue)
                }
            }
        }
        
        return try Data(hex: ABIEncoder.encode(encodedValues))
    }
    
    private func _intSize(type: String, prefix: String) -> UInt16 {
        guard type.starts(with: prefix), let size = UInt16(type.dropFirst(prefix.count)) else {
            return 0
        }
        if size < 8 || size > 256 || size % 8 != 0 {
            return 0
        }
        return size
    }
    
    private func convertSimpleValue(value: SerializableValue, type: String) throws -> SolidityWrappedValue {
        switch type {
        case "string": fallthrough
        case "bytes":
            if let bytes = value.string?.data(using: .utf8) {
                return SolidityWrappedValue(value: bytes.sha3(.keccak256), type: .bytes(length: 32))
            }
        case "bool":
            if let bool = value.bool {
                return SolidityWrappedValue(value: bool, type: .bool)
            }
        case "address":
            if let str = value.string, let address = try? Address(hex: str, eip55: false) {
                return SolidityWrappedValue(value: address, type: .address)
            }
        case let uint where uint.starts(with: "uint"):
            let size = _intSize(type: uint, prefix: "uint")
            guard size > 0 else { throw Error.cantEncodeValue(type, value) }
            if let int = value.int {
                return SolidityWrappedValue(value: Int(int), type: .type(.uint(bits: size)))
            }
            if let str = value.string, let bigInt = BigUInt(value: str) {
                return SolidityWrappedValue(value: bigInt, type: .type(.uint(bits: size)))
            }
        case let int where int.starts(with: "int"):
            let size = _intSize(type: int, prefix: "int")
            guard size > 0 else { throw Error.cantEncodeValue(type, value) }
            if let int = value.int {
                return SolidityWrappedValue(value: Int(int), type: .type(.int(bits: size)))
            }
            if let str = value.string, let bigInt = BigInt(value: str) {
                return SolidityWrappedValue(value: bigInt, type: .type(.int(bits: size)))
            }
        case let bytes where bytes.starts(with: "bytes"):
            if let length = UInt(type.dropFirst("bytes".count)), let string = value.string {
                if string.starts(with: "0x") { // Bytes
                    return SolidityWrappedValue(value: Data(hex: string), type: .bytes(length: length))
                } else { // String
                    if let data = string.data(using: .utf8) {
                        return SolidityWrappedValue(value: data, type: .bytes(length: length))
                    }
                }
            }
        default:
            throw Error.cantEncodeValue(type, value)
        }
        throw Error.cantEncodeValue(type, value)
    }
}

private extension BigInt {
    init?(value: String) {
        if value.starts(with: "0x") {
            self.init(String(value.dropFirst(2)), radix: 16)
        } else {
            self.init(value)
        }
    }
}

private extension BigUInt {
    init?(value: String) {
        if value.starts(with: "0x") {
            self.init(String(value.dropFirst(2)), radix: 16)
        } else {
            self.init(value)
        }
    }
}

private extension TypedData.Domain {
    var serialized: SerializableValue {
        return SerializableValue([
            "name": name, "version": version,
            "chainId": chainId, "verifyingContract": verifyingContract.hex(eip55: false)
        ])
    }
}
