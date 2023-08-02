//
//  File.swift
//  
//
//  Created by Paul Kraft on 27.07.23.
//

import Foundation

public struct Custom<Format: FormatType>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    internal let format: Format

    // MARK: Initialization

    public init<Root, Value>(
        _ keyPath: KeyPath<Root, Value>,
        read: @escaping (inout ReadContainer) -> Value
    ) where Root: Readable, Format == ReadFormat<Root> {
        self.format = ReadFormat { container, context in
            try context.write(read(&container), for: keyPath)
        }
    }

    public init<Root, Value>(
        _ keyPath: KeyPath<Root, Value>,
        write: @escaping (inout WriteContainer, Value) throws -> Void
    ) where Root: Writable, Format == WriteFormat<Root> {
        self.format = WriteFormat { container, root in
            try write(&container, root[keyPath: keyPath])
        }
    }

    public init<Root, Value>(
        _ keyPath: KeyPath<Root, Value>,
        read: @escaping (inout ReadContainer) -> Value,
        write: @escaping (inout WriteContainer, Value) throws -> Void
    ) where Root: ReadWritable, Format == ReadWriteFormat<Root> {
        self.format = ReadWriteFormat(
            read: Custom<ReadFormat>(keyPath, read: read).format,
            write: Custom<WriteFormat>(keyPath, write: write).format
        )
    }

}

extension Custom: ReadableProperty where Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try format.read(from: &container, context: &context)
    }
}

extension Custom: WritableProperty where Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        try format.write(to: &container, using: root)
    }
}
