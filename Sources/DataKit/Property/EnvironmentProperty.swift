// EnvironmentProperty.swift

import Foundation

extension FormatProperty {

    /// Sets a single environment value for the duration of `self`'s read/write.
    ///
    /// The previous value is restored once the wrapped format completes.
    ///
    /// ```swift
    /// \.bigEndianField.environment(\.endianness, .big)
    /// ```
    public func environment<Value: Sendable>(
        _ keyPath: WritableKeyPath<EnvironmentValues, Value>,
        _ value: Value
    ) -> EnvironmentProperty<Self> {
        EnvironmentProperty(self) { $0[keyPath: keyPath] = value }
    }

    /// Mutates a single environment value via a closure for the duration of `self`'s read/write.
    public func transformEnvironment<Value>(
        _ keyPath: WritableKeyPath<EnvironmentValues, Value>,
        transform: @escaping @Sendable (inout Value) throws -> Void
    ) -> EnvironmentProperty<Self> {
        EnvironmentProperty(self) { try transform(&$0[keyPath: keyPath]) }
    }

    /// Mutates the full environment via a closure for the duration of `self`'s read/write.
    public func transformEnvironment(
        transform: @escaping @Sendable (inout EnvironmentValues) throws -> Void
    ) -> EnvironmentProperty<Self> {
        EnvironmentProperty(self) { try transform(&$0) }
    }

}

/// Scopes a transient environment change to a single format subtree.
///
/// Created indirectly via ``FormatProperty/environment(_:_:)``,
/// ``FormatProperty/transformEnvironment(_:transform:)``, or
/// ``FormatProperty/transformEnvironment(transform:)``. The `transform` closure runs before
/// the wrapped format and the previous environment is restored afterwards, giving SwiftUI-
/// style scoped propagation.
public struct EnvironmentProperty<Format: FormatProperty>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    private let format: Format
    private let transform: @Sendable (inout EnvironmentValues) throws -> Void

    // MARK: Initialization

    public init(
        _ format: Format,
        transform: @escaping @Sendable (inout EnvironmentValues) throws -> Void
    ) {
        self.format = format
        self.transform = transform
    }

}

extension EnvironmentProperty: Sendable {}

extension EnvironmentProperty: ReadableProperty where Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        let previousEnvironment = container.environment
        try transform(&container.environment)
        try format.read(from: &container, context: &context)
        container.environment = previousEnvironment
    }
}

extension EnvironmentProperty: WritableProperty where Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        let previousEnvironment = container.environment
        try transform(&container.environment)
        try format.write(to: &container, using: root)
        container.environment = previousEnvironment
    }
}
