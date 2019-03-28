//
//  Serialization.swift
//  EthereumBase
//
//  Created by Yehor Popovych on 3/8/19.
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

public protocol SerializableValueEncodable {
    var serializable: SerializableValue { get }
}

public protocol SerializableValueDecodable {
    init(_ serializable: SerializableValue) throws
}

public typealias SerializableProtocol = SerializableValueDecodable & SerializableValueEncodable

public enum SerializableValue: Codable, SerializableProtocol, Equatable {
    case `nil`
    case bool(Bool)
    case int(Int)
    case float(Double)
    case string(String)
    case array(Array<SerializableValue>)
    case object(Dictionary<String, SerializableValue>)
    
    public init(_ serializable: SerializableValue) {
        self = serializable
    }
    
    public init(from value: SerializableValueEncodable) {
        self = value.serializable
    }
    
    public init(_ dict: Dictionary<String, SerializableValueEncodable>) {
        self = .object(dict.mapValues{ $0.serializable })
    }
    
    public var serializable: SerializableValue {
        return self
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .nil
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let float = try? container.decode(Double.self) {
            self = .float(float)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([SerializableValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: SerializableValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown value type")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .nil: try container.encodeNil()
        case .bool(let bool): try container.encode(bool)
        case .int(let int): try container.encode(int)
        case .float(let num): try container.encode(num)
        case .string(let str): try container.encode(str)
        case .array(let arr): try container.encode(arr)
        case .object(let obj): try container.encode(obj)
        }
    }
    
    public enum Error: Swift.Error {
        case notInitializable(SerializableValue)
    }
}

private struct CustomCodingKeys: CodingKey {
    let stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? { return nil }
    init?(intValue: Int) { return nil }
}

private let DATE_FORMATTER = ISO8601DateFormatter()

extension Int: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .int(let int) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = int
    }
    public var serializable: SerializableValue { return .int(self) }
}
extension SerializableValueDecodable {
    public var int: Int? {
        switch self {
        case let val as SerializableValue:
            guard case .int(let int) = val else { return nil }
            return int
        case let int as Int: return int
        default: return nil
        }
    }
}

extension Double: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .float(let num) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = num
    }
    public var serializable: SerializableValue { return .float(self) }
}
extension SerializableValueDecodable {
    public var float: Double? {
        switch self {
        case let val as SerializableValue:
            guard case .float(let num) = val else { return nil }
            return num
        case let num as Double: return num
        default: return nil
        }
    }
}

extension Bool: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .bool(let bool) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = bool
    }
    public var serializable: SerializableValue { return .bool(self) }
}
extension SerializableValueDecodable {
    public var bool: Bool? {
        switch self {
        case let val as SerializableValue:
            guard case .bool(let bool) = val else { return nil }
            return bool
        case let bool as Bool: return bool
        default: return nil
        }
    }
}

extension Date: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        switch serializable {
        case .string(let str):
            guard let date = DATE_FORMATTER.date(from: str) else {
                throw SerializableValue.Error.notInitializable(serializable)
            }
            self = date
        case .float(let num):
            self = Date(timeIntervalSince1970: num)
        case .int(let int):
            self = Date(timeIntervalSince1970: Double(int))
        default:
            throw SerializableValue.Error.notInitializable(serializable)
        }
    }
    public var serializable: SerializableValue { return .string(DATE_FORMATTER.string(from: self)) }
}
extension SerializableValueDecodable {
    public var date: Date? {
        switch self {
        case let val as SerializableValue:
            return try? Date(val)
        case let str as String:
            return DATE_FORMATTER.date(from: str)
        case let num as Double:
            return Date(timeIntervalSince1970: num)
        case let int as Int:
            return Date(timeIntervalSince1970: Double(int))
        case let date as Date: return date
        default: return nil
        }
    }
}

extension Data: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        switch serializable {
        case .string(let str):
            guard let data = Data(base64Encoded: str) else {
                throw SerializableValue.Error.notInitializable(serializable)
            }
            self = data
        default:
            throw SerializableValue.Error.notInitializable(serializable)
        }
    }
    public var serializable: SerializableValue { return .string(self.base64EncodedString()) }
}
extension SerializableValueDecodable {
    public var data: Data? {
        switch self {
        case let val as SerializableValue:
            return try? Data(val)
        case let str as String:
            return Data(base64Encoded: str)
        case let data as Data: return data
        default: return nil
        }
    }
}

extension String: SerializableProtocol {
    public init(_ serializable: SerializableValue) throws {
        guard case .string(let str) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = str
    }
    public var serializable: SerializableValue { return .string(self) }
}
extension SerializableValueDecodable {
    public var string: String? {
        switch self {
        case let val as SerializableValue:
            guard case .string(let str) = val else { return nil }
            return str
        case let str as String: return str
        default: return nil
        }
    }
}

extension Array: SerializableValueEncodable where Element: SerializableValueEncodable {
    public var serializable: SerializableValue { return .array(self.map{$0.serializable}) }
}
extension Array: SerializableValueDecodable where Element: SerializableValueDecodable {
    public init(_ serializable: SerializableValue) throws {
        guard case .array(let array) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = try array.map{ try Element($0) }
    }
}
extension SerializableValueDecodable {
    public var array: Array<SerializableValue>? {
        switch self {
        case let val as SerializableValue:
            guard case .array(let array) = val else { return nil }
            return array
        case let array as Array<SerializableValue>: return array
        case let array as Array<SerializableProtocol>: return array.map{$0.serializable}
        default: return nil
        }
    }
}

extension Dictionary: SerializableValueDecodable where Key == String, Value: SerializableValueDecodable {
    public init(_ serializable: SerializableValue) throws {
        guard case .object(let obj) = serializable else { throw SerializableValue.Error.notInitializable(serializable) }
        self = try obj.mapValues { try Value($0) }
    }
}

extension Dictionary: SerializableValueEncodable where Key == String, Value: SerializableValueEncodable {
    public var serializable: SerializableValue {
        return .object(self.mapValues { $0.serializable })
    }
}

extension SerializableValueDecodable {
    public var object: Dictionary<String, SerializableValue>? {
        switch self {
        case let val as SerializableValue:
            guard case .object(let obj) = val else { return nil }
            return obj
        case let object as Dictionary<String, SerializableValue>: return object
        case let dict as Dictionary<String, SerializableProtocol>: return dict.mapValues { $0.serializable }
        default: return nil
        }
    }
}

extension Optional: SerializableValueEncodable where Wrapped: SerializableValueEncodable {
    public var serializable: SerializableValue {
        switch self {
        case .none: return .nil
        case .some(let val): return val.serializable
        }
    }
}
extension Optional: SerializableValueDecodable where Wrapped: SerializableValueDecodable {
    public init(_ serializable: SerializableValue) throws {
        switch serializable {
        case .nil: self = .none
        default: self = try .some(Wrapped(serializable))
        }
    }
}

extension Optional {
    public static var `nil`: SerializableProtocol {
        return SerializableValue.nil
    }
}
