// KeyPath.swift

import Foundation

// Conformances that let a bare key path expression (e.g. `\.magic`) participate in format
// builders. These are equivalent to wrapping the key path in `Property(_:)`.

extension KeyPath: FormatProperty {}

extension KeyPath: ReadableProperty where Root: Readable, Value: Readable {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try context.write(Value(from: &container), for: self)
    }
}

extension KeyPath: WritableProperty where Root: Writable, Value: Writable {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        try root[keyPath: self].write(to: &container)
    }
}
