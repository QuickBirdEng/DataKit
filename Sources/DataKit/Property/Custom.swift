// Custom.swift

import Foundation

/// Drops down to raw `ReadContainer`/`WriteContainer` access for a single field.
///
/// `Custom` is the escape hatch for fields that cannot be expressed with the existing
/// primitives or with a ``Convert`` + ``Conversion``. The `read` closure is not annotated
/// `throws` in its signature, but it is invoked inside a throwing context — call sites can
/// throw via `try` inside the closure body using `try!`/`try?` patterns or by lifting the
/// logic into a helper that throws.
///
/// If the same custom read/write logic appears more than once in your codebase, lift it
/// into a reusable ``Conversion`` or ``ReversibleConversion`` instead.
public struct Custom<Format: FormatType>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    internal let format: Format

    // MARK: Initialization

    /// Read-only custom logic.
    public init<Root, Value>(
        _ keyPath: KeyPath<Root, Value>,
        read: @escaping (inout ReadContainer) -> Value
    ) where Root: Readable, Format == ReadFormat<Root> {
        self.format = ReadFormat { container, context in
            try context.write(read(&container), for: keyPath)
        }
    }

    /// Write-only custom logic.
    public init<Root, Value>(
        _ keyPath: KeyPath<Root, Value>,
        write: @escaping (inout WriteContainer, Value) throws -> Void
    ) where Root: Writable, Format == WriteFormat<Root> {
        self.format = WriteFormat { container, root in
            try write(&container, root[keyPath: keyPath])
        }
    }

    /// Paired custom read and write for a ``ReadWritable`` root.
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
