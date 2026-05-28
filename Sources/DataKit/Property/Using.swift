// Using.swift

import Foundation

/// Builds a sub-format that depends on a value already read into the context (or already
/// present on the root, during a write).
///
/// `Using` is the workhorse for length-prefixed and feature-flagged formats: a count or flag
/// byte is parsed first, then `Using` branches on that value to decide what to read next.
/// Unlike ``Property``, `Using` does **not** itself read bytes — it consumes a value that an
/// earlier statement already produced.
///
/// On read, `Using` retrieves the value from `ReadContext` via `keyPath` (which means a
/// matching `Property(\.kp)` / `\.kp` must precede it). On write, it reads the value
/// directly off `root` via the same key path. The builder closure is invoked once per pass.
public struct Using<Value, Format: FormatType>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    private let keyPath: KeyPath<Root, Value>
    private let format: (Value) throws -> Format

    // MARK: Initialization

    /// Read-only branching on a previously-read value.
    public init<Root: Readable>(
        _ keyPath: KeyPath<Root, Value>,
        @FormatBuilder<Root, Format> with format: @escaping (Value) throws -> Format
    ) where Format == ReadFormat<Root> {
        self.keyPath = keyPath
        self.format = format
    }

    /// Write-only branching on a value carried by `root`.
    public init<Root: Writable>(
        _ keyPath: KeyPath<Root, Value>,
        @FormatBuilder<Root, Format> with format: @escaping (Value) throws -> Format
    ) where Format == WriteFormat<Root> {
        self.keyPath = keyPath
        self.format = format
    }

    /// Read+write branching for a ``ReadWritable`` root.
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
