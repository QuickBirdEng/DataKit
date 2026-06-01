// ReadWritable.swift

import Foundation

/// A type that can be both decoded from and encoded to binary `Data` using a single
/// declarative format.
///
/// `ReadWritable` is the recommended conformance when your type round-trips in both
/// directions. You declare the byte layout once via ``format``; the synthesized
/// ``Readable/readFormat`` and ``Writable/writeFormat`` are derived from it automatically.
///
/// ```swift
/// struct Header: ReadWritable {
///     var magic: UInt16
///     var count: UInt8
///
///     init(from context: ReadContext<Header>) throws {
///         magic = try context.read(for: \.magic)
///         count = try context.read(for: \.count)
///     }
///
///     static var format: Format {
///         \.magic
///         \.count
///     }
/// }
/// ```
///
/// The same key-path-matching requirement from ``Readable`` applies: every key path
/// declared in ``format`` must also be retrieved from `ReadContext` in `init(from:)`.
public protocol ReadWritable: Readable, Writable {

    /// The unified declarative description of how to read and write `Self`.
    ///
    /// Each statement runs once on decode and once on encode. Operations that only make
    /// sense in one direction (asserting magic bytes, computing a checksum) are handled
    /// symmetrically by the framework.
    @FormatBuilder
    static var format: Format { get throws }

}

extension ReadWritable {

    public typealias FormatBuilder = ReadWriteFormatBuilder<Self>
    public typealias Format = ReadWriteFormat<Self>

    public static var readFormat: ReadFormat<Self> {
        get throws {
            let format = try format
            return ReadFormat { container, context in
                try format.read(from: &container, context: &context)
            }
        }
    }

    public static var writeFormat: WriteFormat<Self> {
        get throws {
            let format = try format
            return WriteFormat { container, root in
                try format.write(to: &container, using: root)
            }
        }
    }

}
