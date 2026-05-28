// Readable.swift

import Foundation

/// A type that can be decoded from binary `Data` using a declarative format.
///
/// Conforming types provide two things:
///
/// - A static ``readFormat`` that uses the `@ReadBuilder` result builder DSL to describe the
///   byte layout. Each statement parses bytes and stores values into a `ReadContext`,
///   keyed by `KeyPath<Self, Value>`.
/// - An initializer ``init(from:)`` that constructs the value from the populated `ReadContext`.
///
/// The key paths used in `readFormat` and in `init(from:)` must match. Mismatches are not
/// caught by the compiler and surface as `ReadContext.ValueDoesNotExistError` at runtime.
///
/// A simple example:
///
/// ```swift
/// struct Header: Readable {
///     var magic: UInt16
///     var count: UInt8
///
///     init(from context: ReadContext<Header>) throws {
///         magic = try context.read(for: \.magic)
///         count = try context.read(for: \.count)
///     }
///
///     static var readFormat: ReadFormat<Header> {
///         \.magic
///         \.count
///     }
/// }
///
/// let header = try Header(data)
/// ```
///
/// If your type round-trips in both directions, prefer ``ReadWritable`` so you only declare
/// the format once.
public protocol Readable {

    /// Builds the value from the populated context after the format walk has run.
    ///
    /// - Parameter context: A scratchpad populated by ``readFormat``, keyed by `KeyPath<Self, Value>`.
    /// - Throws: Errors raised by ``ReadContext/read(for:)`` and ``ReadContext/readIfPresent(for:)``,
    ///   or any error thrown by the implementer.
    init(from context: ReadContext<Self>) throws

    /// The declarative description of how to parse `Self` from bytes.
    ///
    /// Each statement runs in order against the active `ReadContainer`. A bare key path
    /// (e.g. `\.magic`) is equivalent to `Property(\.magic)`: it parses a `Value` from the
    /// container and stores it in the `ReadContext` under that key path.
    @ReadBuilder
    static var readFormat: ReadFormat<Self> { get throws }

}

extension Readable {

    public typealias ReadBuilder = ReadFormatBuilder<Self>

    /// Reads `Self` from an in-flight `ReadContainer`. Used internally when one `Readable`
    /// is nested inside another's format.
    ///
    /// - Throws: Whatever ``readFormat`` and ``init(from:)`` throw.
    public init(from container: inout ReadContainer) throws {
        var context = ReadContext<Self>()
        try Self.readFormat.read(from: &container, context: &context)
        try self.init(from: context)
    }

    /// Decodes `Self` from a complete `Data` value.
    ///
    /// - Parameters:
    ///   - data: The raw bytes to decode.
    ///   - environment: Initial environment values (endianness, suffix terminator, etc.).
    /// - Throws: Whatever ``readFormat`` and ``init(from:)`` throw.
    public init(_ data: Data, environment: EnvironmentValues = EnvironmentValues()) throws {
        var container = ReadContainer(data: data, environment: environment)
        try self.init(from: &container)
    }

    /// Decodes `Self` from a complete `Data` value, configuring the environment via a closure.
    ///
    /// Use this overload when you want to set environment values inline at the call site,
    /// for example to enforce a particular endianness:
    ///
    /// ```swift
    /// let value = try Packet(data) { $0.endianness = .big }
    /// ```
    public init(_ data: Data, transform: (inout EnvironmentValues) throws -> Void) throws {
        var environment = EnvironmentValues()
        try transform(&environment)
        try self.init(data, environment: environment)
    }

}
