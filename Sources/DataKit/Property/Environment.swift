//
//  File.swift
//  
//
//  Created by Paul Kraft on 15.07.23.
//

import Foundation

public struct Environment<Value, Format: FormatType>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    private let keyPath: KeyPath<EnvironmentValues, Value>
    private let format: (Value) throws -> Format

    // MARK: Initialization

    public init<Root: Readable> (
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        @FormatBuilder<Root, Format> format: @escaping (Value) throws -> Format
    ) where Format == ReadFormat<Root> {
        self.keyPath = keyPath
        self.format = format
    }

    public init<Root: Writable> (
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        @FormatBuilder<Root, Format> format: @escaping (Value) throws -> Format
    ) where Format == WriteFormat<Root> {
        self.keyPath = keyPath
        self.format = format
    }

    public init<Root: ReadWritable> (
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        @FormatBuilder<Root, Format> format: @escaping (Value) throws -> Format
    ) where Format == ReadWriteFormat<Root> {
        self.keyPath = keyPath
        self.format = format
    }

}

extension Environment: ReadableProperty where Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        let value = container.environment[keyPath: keyPath]
        try format(value).read(from: &container, context: &context)
    }
}

extension Environment: WritableProperty where Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        let value = container.environment[keyPath: keyPath]
        try format(value).write(to: &container, using: root)
    }
}
