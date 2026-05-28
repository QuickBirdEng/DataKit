// ReadWritable+Raw.swift

import Foundation

// `RawRepresentable` types whose `RawValue` is itself `ReadWritable` (the common case for
// enums backed by integer raw values) automatically gain the corresponding conformance.
// Unknown raw values during decode throw `ConversionError`.

extension RawRepresentable where Self: Readable, RawValue: Readable {

    public init(from context: ReadContext<Self>) throws {
        let rawValue = try context.read(for: \.rawValue)
        guard let value = Self(rawValue: rawValue) else {
            throw ConversionError(source: rawValue, targetType: Self.self)
        }
        self = value
    }

    @ReadBuilder
    public static var readFormat: ReadFormat<Self> {
        \.rawValue
    }

}

extension RawRepresentable where Self: Writable, RawValue: Writable {

    @WriteBuilder
    public static var writeFormat: WriteFormat<Self> {
        \.rawValue
    }

}

extension RawRepresentable where Self: ReadWritable, RawValue: ReadWritable {

    @FormatBuilder
    public static var format: Format {
        \.rawValue
    }

}
