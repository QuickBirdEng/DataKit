// ReadWritable+Optional.swift

import Foundation

/// Optional handling in DataKit is asymmetric and worth knowing about explicitly:
///
/// - **Reading** an `Optional<Wrapped>` always parses a `Wrapped` and produces `.some(value)`.
///   The `Optional` typing exists for the *write* side; you never get `nil` back from a
///   read — to make presence optional, use ``Using`` plus
///   ``ReadContext/readIfPresent(for:)`` to conditionally decode.
/// - **Writing** a `nil` produces zero bytes; writing `.some` emits the wrapped value. This
///   is useful for fields whose presence depends on an earlier flag.

extension Optional: Readable where Wrapped: Readable & Sendable {

    public init(from context: ReadContext<Self>) throws {
        self = try context.read(for: \.self)
    }

    public static var readFormat: ReadFormat<Self> {
        ReadFormat { container, context in
            try context.write(.some(Wrapped(from: &container)), for: \.self)
        }
    }

}

extension Optional: Writable where Wrapped: Writable & Sendable {

    public static var writeFormat: WriteFormat<Self> {
        WriteFormat { container, value in
            try value?.write(to: &container)
        }
    }

}

extension Optional: ReadWritable where Wrapped: ReadWritable & Sendable {

    public static var format: Format {
        Format(read: readFormat, write: writeFormat)
    }

}
