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
        conversion makeConversion: Conversion<ConvertedValue, Value>.Make
    ) where Root: Readable, Format == ReadFormat<Root> {
        self.init(
            keyPath,
            convert: Conversion.make(makeConversion).convert
        )
    }

    public init<Root, Value, ConvertedValue: Readable>(
        _ keyPath: KeyPath<Root, Value>,
        convert: @escaping (ConvertedValue) throws -> Value
    ) where Root: Readable, Format == ReadFormat<Root> {
        self.format = ReadFormat { container, context in
            let value = try convert(ConvertedValue(from: &container))
            try context.write(value, for: keyPath)
        }
    }

    public init<Root, Value, ConvertedValue: Writable>(
        _ keyPath: KeyPath<Root, Value>,
        conversion makeConversion: Conversion<Value, ConvertedValue>.Make
    ) where Root: Writable, Format == WriteFormat<Root> {
        self.init(
            keyPath,
            convert: Conversion.make(makeConversion).convert
        )
    }

    public init<Root, Value, ConvertedValue: Writable>(
        _ keyPath: KeyPath<Root, Value>,
        convert: @escaping (Value) throws -> ConvertedValue
    ) where Root: Writable, Format == WriteFormat<Root> {
        self.format = WriteFormat { container, root in
            try convert(root[keyPath: keyPath]).write(to: &container)
        }
    }

    public init<Root, Value, ConvertedValue: ReadWritable>(
        _ keyPath: KeyPath<Root, Value>,
        conversion makeConversion: ReversibleConversion<Value, ConvertedValue>.Make
    ) where Root: ReadWritable, Format == ReadWriteFormat<Root> {
        let conversion = ReversibleConversion.make(makeConversion)
        self.init(keyPath, reading: conversion.convert, writing: conversion.convert)
    }

    public init<Root, Value, ConvertedValue: ReadWritable>(
        _ keyPath: KeyPath<Root, Value>,
        reading: @escaping (ConvertedValue) throws -> Value,
        writing: @escaping (Value) throws -> ConvertedValue
    ) where Root: ReadWritable, Format == ReadWriteFormat<Root> {
        self.format = ReadWriteFormat(
            read: .init { container, context in
                let value = try reading(ConvertedValue(from: &container))
                try context.write(value, for: keyPath)
            },
            write: .init { container, root in
                try writing(root[keyPath: keyPath]).write(to: &container)
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


