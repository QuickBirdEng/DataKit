// Property.swift

import Foundation

/// Wraps a key path so it can appear in a format builder when the surrounding context
/// cannot infer the `Root` type from a bare `\.foo`.
///
/// In most cases, a bare key path inside a format block (e.g. `\.magic`) is enough — the
/// conformance in `KeyPath.swift` adopts ``ReadableProperty`` and ``WritableProperty`` for you.
/// Reach for `Property` only when the compiler complains about the root type, or when you
/// need to chain fluent methods like ``conversion(_:)`` / ``converted(_:)``.
public struct Property<Root, Value>: FormatProperty {

    // MARK: Stored Properties

    internal let keyPath: KeyPath<Root, Value>

    // MARK: Initialization

    /// Wraps `keyPath` so it can be used inside a format builder.
    public init(_ keyPath: KeyPath<Root, Value>) {
        self.keyPath = keyPath
    }

}

extension Property: ReadableProperty where Root: Readable, Value: Readable {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        let value = try Value(from: &container)
        try context.write(value, for: keyPath)
    }
}

extension Property: WritableProperty where Root: Writable, Value: Writable {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        try root[keyPath: keyPath].write(to: &container)
    }
}
