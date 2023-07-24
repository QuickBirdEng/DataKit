//
//  File.swift
//  
//
//  Created by Paul Kraft on 14.07.23.
//

import Foundation

public struct Property<Root, Value, Format: FormatType>: FormatProperty where Root == Format.Root {

    // MARK: Stored Properties

    internal let keyPath: KeyPath<Root, Value>
    internal let format: Format

}

extension Property where Root: Readable, Format == ReadFormat<Root> {

    public init(
        _ keyPath: KeyPath<Root, Value>,
        read: @escaping (inout ReadContainer) throws -> Value
    ) {
        self.keyPath = keyPath
        self.format = .init { container, context in
            try context.write(read(&container), for: keyPath)
        }
    }

    public init(
        _ keyPath: KeyPath<Root, Value>
    ) where Value: Readable {
        self.init(keyPath) { container in
            try Value(from: &container)
        }
    }

    public init<ActualValue: Readable>(
        _ keyPath: KeyPath<Root, Value>,
        as conversion: UnidirectionalConversion<ActualValue, Value>
    ) {
        self.init(keyPath) { container in
            try conversion.convert(ActualValue(from: &container))
        }
    }

}

extension Property where Root: Writable, Format == WriteFormat<Root> {

    public init(
        _ keyPath: KeyPath<Root, Value>,
        write: @escaping (inout WriteContainer, Value) throws -> Void
    ) {
        self.keyPath = keyPath
        self.format = .init { container, value in
            try write(&container, value[keyPath: keyPath])
        }
    }

    public init(
        _ keyPath: KeyPath<Root, Value>
    ) where Value: Writable {
        self.init(keyPath) { container, value in
            try value.write(to: &container)
        }
    }

    public init<ActualValue: Writable>(
        _ keyPath: KeyPath<Root, Value>,
        as conversion: UnidirectionalConversion<Value, ActualValue>
    ) {
        self.init(keyPath) { container, value in
            try conversion.convert(value).write(to: &container)
        }
    }

}

extension Property where Root: ReadWritable, Format == ReadWriteFormat<Root> {

    public init(
        _ keyPath: KeyPath<Root, Value>,
        read: @escaping (inout ReadContainer) throws -> Value,
        write: @escaping (inout WriteContainer, Value) throws -> Void
    ) {
        self.keyPath = keyPath
        self.format = .init { container, context in
            try context.write(read(&container), for: keyPath)
        } write: { container, root in
            try write(&container, root[keyPath: keyPath])
        }
    }

    public init(
        _ keyPath: KeyPath<Root, Value>
    ) where Value: ReadWritable {
        self.init(keyPath) { container in
            try Value(from: &container)
        } write: { container, value in
            try value.write(to: &container)
        }
    }

    public init<ActualValue: ReadWritable>(
        _ keyPath: KeyPath<Root, Value>,
        as conversion: BidirectionalConversion<Value, ActualValue>
    ) {
        self.init(keyPath) { container in
            try conversion.convert(ActualValue(from: &container))
        } write: { container, value in
            try conversion.convert(value).write(to: &container)
        }
    }

}

extension Property: ReadableProperty where Root: Readable, Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try format.read(from: &container, context: &context)
    }
}

extension Property: WritableProperty where Root: Writable, Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        try format.write(to: &container, using: root)
    }
}

extension Property: ReadWritableProperty where Root: ReadWritable, Format: ReadWritableProperty {}
