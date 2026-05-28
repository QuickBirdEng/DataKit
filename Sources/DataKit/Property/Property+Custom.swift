// Property+Custom.swift

import Foundation

extension Property where Root: Readable {

    /// Fluent equivalent of `Custom(\.kp, read: ...)`.
    public func read(
        _ read: @escaping (inout ReadContainer) -> Value
    ) -> Custom<ReadFormat<Root>> {
        Custom(keyPath, read: read)
    }

}

extension Property where Root: Writable {

    /// Fluent equivalent of `Custom(\.kp, write: ...)`.
    public func write(
        _ write: @escaping (inout WriteContainer, Value) throws -> Void
    ) -> Custom<WriteFormat<Root>> {
        Custom(keyPath, write: write)
    }

}

extension Property where Root: ReadWritable {

    /// Fluent equivalent of `Custom(\.kp, read:write:)`.
    public func read(
        _ read: @escaping (inout ReadContainer) -> Value,
        write: @escaping (inout WriteContainer, Value) throws -> Void
    ) -> Custom<ReadWriteFormat<Root>> {
        Custom(keyPath, read: read, write: write)
    }

}
