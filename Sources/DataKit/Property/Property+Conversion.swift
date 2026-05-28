// Property+Conversion.swift

import Foundation

extension Property where Root: Readable {

    /// Fluent equivalent of `Convert(\.kp, conversion: ...)` for reading.
    public func conversion<ConvertedValue: Readable>(
        _ makeConversion: Conversion<ConvertedValue, Value>.Make
    ) -> Convert<ReadFormat<Root>> {
        Convert(keyPath, conversion: makeConversion)
    }

    /// Fluent equivalent of `Convert(\.kp, convert: ...)` for reading.
    public func converted<ConvertedValue: Readable>(
        _ convert: @escaping (ConvertedValue) throws -> Value
    ) -> Convert<ReadFormat<Root>> {
        Convert(keyPath, convert: convert)
    }

}

extension Property where Root: Writable {

    /// Fluent equivalent of `Convert(\.kp, conversion: ...)` for writing.
    public func conversion<ConvertedValue: Writable>(
        _ makeConversion: Conversion<Value, ConvertedValue>.Make
    ) -> Convert<WriteFormat<Root>> {
        Convert(keyPath, conversion: makeConversion)
    }

    /// Fluent equivalent of `Convert(\.kp, convert: ...)` for writing.
    public func converted<ConvertedValue: Writable>(
        _ convert: @escaping (Value) throws -> ConvertedValue
    ) -> Convert<WriteFormat<Root>> {
        Convert(keyPath, convert: convert)
    }

}

extension Property where Root: ReadWritable {

    /// Fluent equivalent of `Convert(\.kp, conversion: ...)` for read+write.
    public func conversion<ConvertedValue: ReadWritable>(
        _ makeConversion: ReversibleConversion<Value, ConvertedValue>.Make
    ) -> Convert<ReadWriteFormat<Root>> {
        Convert(keyPath, conversion: makeConversion)
    }

    /// Fluent equivalent of `Convert(\.kp, reading:writing:)`.
    public func converted<ConvertedValue: ReadWritable>(
        reading: @escaping (ConvertedValue) throws -> Value,
        writing: @escaping (Value) throws -> ConvertedValue
    ) -> Convert<ReadWriteFormat<Root>> {
        Convert(keyPath, reading: reading, writing: writing)
    }

}
