//
//  File.swift
//  
//
//  Created by Paul Kraft on 22.06.23.
//

import Foundation

public struct ReadContext<Root: Readable> {

    // MARK: Nested Types

    public struct ValueDoesNotExistError: Error {
        public let keyPath: PartialKeyPath<Root>
    }

    public struct ValueTypeMismatchError: Error {
        public let value: Any
        public let expectedType: Any.Type
    }

    // MARK: Stored Properties

    private var values = [PartialKeyPath<Root>: Any]()

    // MARK: Initialization

    public init() {}

    // MARK: Methods

    public mutating func write<Value>(_ value: Value, for keyPath: KeyPath<Root, Value>) throws {
        values[keyPath] = value
    }

    public func read<Value>(for keyPath: KeyPath<Root, Value>) throws -> Value {
        guard let value = values[keyPath] else {
            throw ValueDoesNotExistError(keyPath: keyPath)
        }
        guard let result = value as? Value else {
            throw ValueTypeMismatchError(value: value, expectedType: Value.self)
        }
        return result
    }

    public func readIfPresent<Value>(for keyPath: KeyPath<Root, Value>) throws -> Value? {
        guard let value = values[keyPath] else {
            return nil
        }
        guard let result = value as? Value else {
            throw ValueTypeMismatchError(value: value, expectedType: Value.self)
        }
        return result
    }

    public func readIfPresent<Value>(for keyPath: KeyPath<Root, Value?>) throws -> Value? {
        guard let value = values[keyPath] else {
            return nil
        }
        guard let result = value as? Value else {
            throw ValueTypeMismatchError(value: value, expectedType: Value.self)
        }
        return result
    }

}
