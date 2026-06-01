// Environment.swift

import Foundation

/// Reads a value out of ``EnvironmentValues`` at format-walk time and feeds it into a
/// sub-format builder.
///
/// `Environment` is the format-level analogue of SwiftUI's `@Environment` property wrapper:
/// it lets a format adapt to ambient state (endianness, suffix terminator, etc.) without
/// the call site having to thread that state through every call.
///
/// `Environment` is similar to ``Using`` but reads from the *environment* rather than from
/// the model. Use `Using` when the value depends on the parsed data; use `Environment`
/// when it depends on configuration applied by an outer modifier.
public struct Environment<Value, Format: FormatType>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    private let keyPath: KeyPath<EnvironmentValues, Value>
    private let format: @Sendable (Value) throws -> Format

    // MARK: Initialization

    /// Read-only variant.
    public init<Root: Readable> (
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        @FormatBuilder<Root, Format> format: @escaping @Sendable (Value) throws -> Format
    ) where Format == ReadFormat<Root> {
        self.keyPath = keyPath
        self.format = format
    }

    /// Write-only variant.
    public init<Root: Writable> (
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        @FormatBuilder<Root, Format> format: @escaping @Sendable (Value) throws -> Format
    ) where Format == WriteFormat<Root> {
        self.keyPath = keyPath
        self.format = format
    }

    /// Read+write variant for a ``ReadWritable`` root.
    public init<Root: ReadWritable> (
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        @FormatBuilder<Root, Format> format: @escaping @Sendable (Value) throws -> Format
    ) where Format == ReadWriteFormat<Root> {
        self.keyPath = keyPath
        self.format = format
    }

}

extension Environment: Sendable {}

extension Environment: ReadableProperty where Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        let value = container.environment[keyPath: keyPath]
        try format(value).read(from: &container, context: &context)
    }
}

extension Environment: WritableProperty where Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        let value = container.environment[keyPath: keyPath]
        try format(value).write(to: &container, using: root)
    }
}
