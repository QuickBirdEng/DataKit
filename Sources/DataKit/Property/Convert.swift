//
//  File.swift
//
//
//  Created by Paul Kraft on 27.07.23.
//

import Foundation

public struct Convert<Format: FormatType>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    internal let format: Format

    // MARK: Initialization

    public init<Root, Value, ConvertedValue: Readable>(
        _ keyPath: KeyPath<Root, Value>,
        conversion makeConversion: UnidirectionalConversion<ConvertedValue, Value>.Make
    ) where Root: Readable, Format == ReadFormat<Root> {
        let convert = UnidirectionalConversion.make(makeConversion).convert
        self.format = ReadFormat { container, context in
            let value = try convert(ConvertedValue(from: &container))
            try context.write(value, for: keyPath)
        }
    }

    public init<Root, Value, ConvertedValue: Writable>(
        _ keyPath: KeyPath<Root, Value>,
        conversion makeConversion: UnidirectionalConversion<Value, ConvertedValue>.Make
    ) where Root: Writable, Format == WriteFormat<Root> {
        let convert = UnidirectionalConversion.make(makeConversion).convert
        self.format = WriteFormat { container, root in
            try convert(root[keyPath: keyPath]).write(to: &container)
        }
    }

    public init<Root, Value, ConvertedValue: ReadWritable>(
        _ keyPath: KeyPath<Root, Value>,
        conversion makeConversion: BidirectionalConversion<Value, ConvertedValue>.Make
    ) where Root: ReadWritable, Format == ReadWriteFormat<Root> {
        let conversion = BidirectionalConversion.make(makeConversion)
        self.format = ReadWriteFormat(
            read: .init { container, context in
                let value = try conversion.convert(ConvertedValue(from: &container))
                try context.write(value, for: keyPath)
            },
            write: .init { container, root in
                try conversion.convert(root[keyPath: keyPath]).write(to: &container)
            }
        )
    }

}

extension Convert: ReadableProperty where Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try format.read(from: &container, context: &context)
    }
}

extension Convert: WritableProperty where Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        try format.write(to: &container, using: root)
    }
}


