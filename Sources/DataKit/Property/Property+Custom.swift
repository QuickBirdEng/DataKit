// Property+Custom.swift

import Foundation

extension Property where Root: Readable, Value: Sendable {

    /// Fluent equivalent of `Custom(\.kp, read: ...)`.
    public func read(
        _ read: @escaping @Sendable (inout ReadContainer) -> Value
    ) -> Custom<ReadFormat<Root>> {
        Custom(keyPath, read: read)
    }

}

extension Property where Root: Writable, Value: Sendable {

    /// Fluent equivalent of `Custom(\.kp, write: ...)`.
    public func write(
        _ write: @escaping @Sendable (inout WriteContainer, Value) throws -> Void
    ) -> Custom<WriteFormat<Root>> {
        Custom(keyPath, write: write)
    }

}

extension Property where Root: ReadWritable, Value: Sendable {

    /// Fluent equivalent of `Custom(\.kp, read:write:)`.
    public func read(
        _ read: @escaping @Sendable (inout ReadContainer) -> Value,
        write: @escaping @Sendable (inout WriteContainer, Value) throws -> Void
    ) -> Custom<ReadWriteFormat<Root>> {
        Custom(keyPath, read: read, write: write)
    }

}
