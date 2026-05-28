// Convert.swift

import Foundation

/// Reads or writes a field using a different on-wire type than the in-memory type.
///
/// `Convert` is the bridge between a model's natural Swift type and the bytes a protocol
/// actually carries. Three variants exist:
///
/// - With a ``Conversion``/``ReversibleConversion`` builder: `Convert(\.field) { $0.exactly(UInt16.self) }`.
/// - With raw closures: `Convert(\.field, convert: { ... })` for one-direction conversions,
///   or `Convert(\.field, reading: { ... }, writing: { ... })` for the symmetric case.
/// - For ``ReadWritable`` roots, the reversible form is required so the conversion runs
///   in both directions.
///
/// For the closure-based read initializer, the closure maps **wire type → in-memory type**.
/// For the closure-based write initializer, the closure maps **in-memory type → wire type**.
public struct Convert<Format: FormatType>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    internal let format: Format

    // MARK: Initialization

    /// Read-only conversion using a ``Conversion`` builder.
    public init<Root, Value, ConvertedValue: Readable>(
        _ keyPath: KeyPath<Root, Value>,
        conversion makeConversion: Conversion<ConvertedValue, Value>.Make
    ) where Root: Readable, Format == ReadFormat<Root> {
        self.init(
            keyPath,
            convert: Conversion.make(makeConversion).convert
        )
    }

    /// Read-only conversion using a raw closure (wire type → in-memory type).
    public init<Root, Value, ConvertedValue: Readable>(
        _ keyPath: KeyPath<Root, Value>,
        convert: @escaping (ConvertedValue) throws -> Value
    ) where Root: Readable, Format == ReadFormat<Root> {
        self.format = ReadFormat { container, context in
            let value = try convert(ConvertedValue(from: &container))
            try context.write(value, for: keyPath)
        }
    }

    /// Write-only conversion using a ``Conversion`` builder.
    public init<Root, Value, ConvertedValue: Writable>(
        _ keyPath: KeyPath<Root, Value>,
        conversion makeConversion: Conversion<Value, ConvertedValue>.Make
    ) where Root: Writable, Format == WriteFormat<Root> {
        self.init(
            keyPath,
            convert: Conversion.make(makeConversion).convert
        )
    }

    /// Write-only conversion using a raw closure (in-memory type → wire type).
    public init<Root, Value, ConvertedValue: Writable>(
        _ keyPath: KeyPath<Root, Value>,
        convert: @escaping (Value) throws -> ConvertedValue
    ) where Root: Writable, Format == WriteFormat<Root> {
        self.format = WriteFormat { container, root in
            try convert(root[keyPath: keyPath]).write(to: &container)
        }
    }

    /// Reversible conversion for a ``ReadWritable`` root, using a ``ReversibleConversion`` builder.
    public init<Root, Value, ConvertedValue: ReadWritable>(
        _ keyPath: KeyPath<Root, Value>,
        conversion makeConversion: ReversibleConversion<Value, ConvertedValue>.Make
    ) where Root: ReadWritable, Format == ReadWriteFormat<Root> {
        let conversion = ReversibleConversion.make(makeConversion)
        self.init(keyPath, reading: conversion.convert, writing: conversion.convert)
    }

    /// Reversible conversion for a ``ReadWritable`` root, using paired raw closures.
    ///
    /// - Parameters:
    ///   - reading: Maps wire type → in-memory type during decode.
    ///   - writing: Maps in-memory type → wire type during encode.
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
