//
//  File.swift
//  
//
//  Created by Paul Kraft on 23.06.23.
//

import Foundation

public struct Using<Value, Format: FormatType>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    private let keyPath: KeyPath<Root, Value>
    private let format: (Value) throws -> Format

    // MARK: Initialization

    public init<Root: Readable>(
        _ keyPath: KeyPath<Root, Value>,
        @FormatBuilder<Root, Format> with format: @escaping (Value) throws -> Format
    ) where Format == ReadFormat<Root> {
        self.keyPath = keyPath
        self.format = format
    }

    public init<Root: Writable>(
        _ keyPath: KeyPath<Root, Value>,
        @FormatBuilder<Root, Format> with format: @escaping (Value) throws -> Format
    ) where Format == WriteFormat<Root> {
        self.keyPath = keyPath
        self.format = format
    }

    public init<Root: ReadWritable>(
        _ keyPath: KeyPath<Root, Value>,
        @FormatBuilder<Root, Format> with format: @escaping (Value) throws -> Format
    ) where Format == ReadWriteFormat<Root> {
        self.keyPath = keyPath
        self.format = format
    }

}

extension Using: ReadableProperty where Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        let value = try context.read(for: keyPath)
        try format(value).read(from: &container, context: &context)
    }
}

extension Using: WritableProperty where Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        let value = root[keyPath: keyPath]
        try format(value).write(to: &container, using: root)
    }
}
