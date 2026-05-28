// EnvironmentValues.swift

import Foundation

/// A key for a custom value in ``EnvironmentValues``.
///
/// Following the SwiftUI pattern: declare a private enum that conforms to `EnvironmentKey`
/// with a `defaultValue`, then extend ``EnvironmentValues`` with a property that uses the
/// key's subscript. The compiler-synthesized storage in `EnvironmentValues` is keyed by the
/// metatype identity of the conforming key.
///
/// ```swift
/// private enum MyKey: EnvironmentKey {
///     static var defaultValue: Int { 0 }
/// }
///
/// extension EnvironmentValues {
///     public var myValue: Int {
///         get { self[MyKey.self] }
///         set { self[MyKey.self] = newValue }
///     }
/// }
/// ```
public protocol EnvironmentKey {
    associatedtype Value

    /// The value returned when no entry has been written for this key.
    static var defaultValue: Value { get }
}

/// A SwiftUI-style ambient context propagated through the format walk.
///
/// `EnvironmentValues` is carried by both ``ReadContainer`` and ``WriteContainer`` and reads
/// supply ambient information that the format walk needs but does not want to thread
/// through every call (endianness, the suffix terminator for dynamic-count sequences,
/// whether to skip checksum verification, etc.).
///
/// Built-in keys: ``endianness`` (default `nil` = host-native), ``suffix`` (default `nil`),
/// ``skipChecksumVerification`` (default `false`). Add custom keys by declaring an
/// ``EnvironmentKey`` and extending `EnvironmentValues`.
public struct EnvironmentValues {

    // MARK: Stored Properties

    private var values = [ObjectIdentifier: Any]()

    // MARK: Initialization

    /// Creates an empty environment with all keys at their default values.
    public init() {}

    // MARK: Methods

    /// Reads or writes the value associated with `key`.
    public subscript<Key: EnvironmentKey>(_ key: Key.Type) -> Key.Value {
        get { values[ObjectIdentifier(Key.self), default: Key.defaultValue] as! Key.Value }
        set { values[ObjectIdentifier(Key.self)] = newValue }
    }

}
