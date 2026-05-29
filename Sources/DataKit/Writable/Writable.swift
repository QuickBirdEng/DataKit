// Writable.swift

import Foundation

/// A type that can be encoded to binary `Data` using a declarative format.
///
/// Conforming types provide a static ``writeFormat`` that describes the byte layout. Unlike
/// ``Readable``, no scratchpad is involved: the format walk reads values directly off `self`
/// using the key paths in the declaration.
///
/// ```swift
/// struct Header: Writable {
///     var magic: UInt16
///     var count: UInt8
///
///     static var writeFormat: WriteFormat<Header> {
///         \.magic
///         \.count
///     }
/// }
///
/// let bytes: Data = try header.write()
/// ```
///
/// If your type round-trips in both directions, prefer ``ReadWritable`` so you only declare
/// the format once.
public protocol Writable: Sendable {

    /// The declarative description of how to serialize `Self` into bytes.
    ///
    /// Each statement runs in order against the active `WriteContainer`. A bare key path
    /// (e.g. `\.magic`) is equivalent to `Property(\.magic)`: it reads the property value
    /// off `self` and appends its bytes.
    @WriteBuilder
    static var writeFormat: WriteFormat<Self> { get throws }

}

extension Writable {

    public typealias WriteBuilder = WriteFormatBuilder<Self>

    /// Writes `self` into an in-flight `WriteContainer`. Used internally when one
    /// `Writable` is nested inside another's format.
    ///
    /// - Throws: Whatever ``writeFormat`` throws.
    public func write(to container: inout WriteContainer) throws {
        try Self.writeFormat.write(to: &container, using: self)
    }

    /// Encodes `self` into a fresh `Data` value.
    ///
    /// - Parameter environment: Initial environment values (endianness, suffix terminator, etc.).
    /// - Returns: The serialized bytes.
    /// - Throws: Whatever ``writeFormat`` throws.
    public func write(with environment: EnvironmentValues = EnvironmentValues()) throws -> Data {
        var container = WriteContainer(environment: environment)
        try write(to: &container)
        return container.data
    }

    /// Encodes `self` into a fresh `Data` value, configuring the environment via a closure.
    ///
    /// ```swift
    /// let bytes = try packet.write { $0.endianness = .big }
    /// ```
    public func write(transform: (inout EnvironmentValues) throws -> Void) throws -> Data {
        var environment = EnvironmentValues()
        try transform(&environment)
        return try write(with: environment)
    }

}
