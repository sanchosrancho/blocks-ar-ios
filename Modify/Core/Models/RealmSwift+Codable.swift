//
//  RealmSwift+Codable.swift
//
//  Created by Michael Gray on 8/16/17.
//
import Foundation
import RealmSwift

// swiftlint:disable line_length identifier_name
// stolen functions from the Swift stdlib
// https://github.com/apple/swift/blob/2e5817ebe15b8c2fc2459e08c1d462053cbb9a99/stdlib/public/core/Codable.swift
//
func assertTypeIsEncodable<T>(_ type: T.Type, in wrappingType: Any.Type) {
    guard T.self is Encodable.Type else {
        if T.self == Encodable.self || T.self == Codable.self {
            preconditionFailure("\(wrappingType) does not conform to Encodable because Encodable does not conform to itself. You must use a concrete type to encode or decode.")
        } else {
            preconditionFailure("\(wrappingType) does not conform to Encodable because \(T.self) does not conform to Encodable.")
        }
    }
}

func assertTypeIsDecodable<T>(_ type: T.Type, in wrappingType: Any.Type) {
    guard T.self is Decodable.Type else {
        if T.self == Decodable.self || T.self == Codable.self {
            preconditionFailure("\(wrappingType) does not conform to Decodable because Decodable does not conform to itself. You must use a concrete type to encode or decode.")
        } else {
            preconditionFailure("\(wrappingType) does not conform to Decodable because \(T.self) does not conform to Decodable.")
        }
    }
}

extension Encodable {
    func __encode(to container: inout SingleValueEncodingContainer) throws { try container.encode(self) }
    func __encode(to container: inout UnkeyedEncodingContainer)     throws { try container.encode(self) }
    func __encode<Key>(to container: inout KeyedEncodingContainer<Key>, forKey key: Key) throws { try container.encode(self, forKey: key) }
}

extension Decodable {
    // Since we cannot call these __init, we'll give the parameter a '__'.
    fileprivate init(__from container: SingleValueDecodingContainer)   throws { self = try container.decode(Self.self) }
    fileprivate init(__from container: inout UnkeyedDecodingContainer) throws { self = try container.decode(Self.self) }
    fileprivate init<Key>(__from container: KeyedDecodingContainer<Key>, forKey key: Key) throws { self = try container.decode(Self.self, forKey: key) }
}


extension RealmOptional : Encodable /* where Wrapped : Encodable */ {
    public func encode(to encoder: Encoder) throws {
        assertTypeIsEncodable(T.self, in: type(of: self))
        
        var container = encoder.singleValueContainer()
        if let v = self.value {
            try (v as! Encodable).encode(to: encoder)  // swiftlint:disable:this force_cast
        } else {
            try container.encodeNil()
        }
    }
}

extension RealmOptional : Decodable /* where Wrapped : Decodable */ {
    public convenience init(from decoder: Decoder) throws {
        // Initialize self here so we can get type(of: self).
        self.init()
        assertTypeIsDecodable(T.self, in: type(of: self))
        
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            let metaType = (T.self as! Decodable.Type) // swiftlint:disable:this force_cast
            let element = try metaType.init(from: decoder)
            self.value = (element as! T)  // swiftlint:disable:this force_cast
        }
    }
}
extension List : Decodable /* where Element : Decodable */ {
    public convenience init(from decoder: Decoder) throws {
        // Initialize self here so we can get type(of: self).
        self.init()
        assertTypeIsDecodable(T.self, in: type(of: self))
        
        let metaType = (T.self as! Decodable.Type) // swiftlint:disable:this force_cast
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let element = try metaType.init(__from: &container)
            self.append(element as! Element) // swiftlint:disable:this force_cast
        }
    }
}

extension List : Encodable /* where Element : Decodable */ {
    public func encode(to encoder: Encoder) throws {
        assertTypeIsEncodable(T.self, in: type(of: self))
        
        var container = encoder.unkeyedContainer()
        for element in self {
            // superEncoder appends an empty element and wraps an Encoder around it.
            // This is normally appropriate for encoding super, but this is really what we want to do.
            let subencoder = container.superEncoder()
            try (element as! Encodable).encode(to: subencoder) // swiftlint:disable:this force_cast
        }
    }
}
