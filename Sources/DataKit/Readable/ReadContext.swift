// ReadContext.swift

import Foundation

/// A keyed scratchpad that bridges the format walk and the `init(from:)` initializer.
///
/// `ReadContext` is the link between the two phases of decoding a `Readable`:
///
/// 1. The format walk parses values from the input bytes and stores each one keyed by a
///    `KeyPath<Root, Value>`. This is done implicitly when you write `\.foo` in a format
///    declaration or explicitly via `Property(\.foo)`.
/// 2. Your `init(from context: ReadContext<Self>)` initializer pulls those values back out
///    using the *same* key paths.
///
/// The key paths used in the format walk and in the initializer must match exactly. Mixing
/// them up is not caught by the compiler; instead `read(for:)` throws ``ValueDoesNotExistError``
/// at runtime when the key path was never written, or ``ValueTypeMismatchError`` when the
/// stored type does not match (typically because a `Convert` placed a converted value in
/// the slot).
public struct ReadContext<Root: Readable> {

    // MARK: Nested Types

    /// Thrown by ``ReadContext/read(for:)`` when no value has been written for the requested key path.
    ///
    /// This usually indicates a mismatch between the key paths used in the format declaration
    /// and in `init(from:)`, or a conditional branch in the format that never executed.
    public struct ValueDoesNotExistError: Error, @unchecked Sendable {

        /// The key path for which no value was found.
        public let keyPath: PartialKeyPath<Root>
    }

    /// Thrown by ``ReadContext/read(for:)`` when the stored value's type does not match the requested type.
    ///
    /// Most often this means a value placed via `Convert` was stored under a different runtime
    /// type than the one requested.
    public struct ValueTypeMismatchError: Error, @unchecked Sendable {

        /// The actual value that was stored.
        public let value: Any

        /// The type that was requested.
        public let expectedType: Any.Type
    }

    // MARK: Stored Properties

    private var values = [PartialKeyPath<Root>: Any]()

    // MARK: Initialization

    /// Creates an empty context. Library users do not call this directly — the framework
    /// constructs a fresh context at the start of each read.
    public init() {}

    // MARK: Methods

    /// Stores `value` under `keyPath` so that it can later be retrieved by the matching
    /// `read(for:)`/`readIfPresent(for:)` call in `init(from:)`.
    ///
    /// Implementers of custom `ReadableProperty` types call this from their `read` method.
    /// An existing value at the same key path is overwritten without warning.
    ///
    /// - Throws: This method does not currently throw, but is declared `throws` so that
    ///   future implementations may add validation.
    public mutating func write<Value>(_ value: Value, for keyPath: KeyPath<Root, Value>) throws {
        values[keyPath] = value
    }

    /// Retrieves the value stored under `keyPath`.
    ///
    /// - Parameter keyPath: The key path under which the format walk stored a value.
    /// - Returns: The stored value.
    /// - Throws: ``ValueDoesNotExistError`` if no value was written for the key path.
    ///   ``ValueTypeMismatchError`` if a value was written but its runtime type does not match `Value`.
    public func read<Value>(for keyPath: KeyPath<Root, Value>) throws -> Value {
        guard let value = values[keyPath] else {
            throw ValueDoesNotExistError(keyPath: keyPath)
        }
        guard let result = value as? Value else {
            throw ValueTypeMismatchError(value: value, expectedType: Value.self)
        }
        return result
    }

    /// Retrieves the value stored under `keyPath`, or `nil` if no value was written.
    ///
    /// Use this overload for fields whose presence depends on a runtime condition in the
    /// format (such as a feature flag). A missing value yields `nil`; a value of the
    /// wrong type still throws.
    ///
    /// - Throws: ``ValueTypeMismatchError`` if a value was written but its runtime type
    ///   does not match `Value`.
    public func readIfPresent<Value>(for keyPath: KeyPath<Root, Value>) throws -> Value? {
        guard let value = values[keyPath] else {
            return nil
        }
        guard let result = value as? Value else {
            throw ValueTypeMismatchError(value: value, expectedType: Value.self)
        }
        return result
    }

    /// Retrieves the value stored under an optional-typed key path.
    ///
    /// This overload exists for properties declared `Optional` on `Root` so that the
    /// caller can write `try context.readIfPresent(for: \.maybeField)` and recover the
    /// unwrapped `Wrapped` value directly.
    ///
    /// - Throws: ``ValueTypeMismatchError`` if a value was written but its runtime type
    ///   does not match `Value`.
    public func readIfPresent<Value>(for keyPath: KeyPath<Root, Value?>) throws -> Value? {
        guard let value = values[keyPath] else {
            return nil
        }
        guard let result = value as? Value else {
            throw ValueTypeMismatchError(value: value, expectedType: Value.self)
        }
        return result
    }

}
