// WriteContainer.swift

import Foundation

/// The mutable write cursor passed through the format walk during serialization.
///
/// A `WriteContainer` accumulates `data` and carries the active `EnvironmentValues`.
/// Format properties append bytes via the `append(...)` overloads or via `transform(_:)`
/// for direct mutable access (useful when back-patching, e.g. writing a value and then
/// updating an earlier length field).
///
/// Unlike `ReadContainer`, a write container does not maintain a separate cursor — every
/// append moves the end of `data` forward. To carve out a sub-buffer (for example, to
/// compute a checksum over a contained region), use a `Scope`.
public struct WriteContainer {

    // MARK: Stored Properties

    /// The bytes accumulated so far. Read-only externally; grows via the `append(...)`
    /// methods or in-place mutation through `transform(_:)`.
    public private(set) var data: Data

    /// The active environment (endianness, suffix terminator, etc.).
    public var environment: EnvironmentValues

    // MARK: Initialization

    /// Creates a write container with an optional pre-populated buffer.
    public init(
        data: Data = Data(),
        environment: EnvironmentValues
    ) {
        self.data = data
        self.environment = environment
    }

    // MARK: Methods

    /// Gives the caller mutable access to the underlying buffer. Useful for in-place edits
    /// such as back-patching a length field after the payload has been written.
    public mutating func transform<V>(_ transform: (inout Data) throws -> V) rethrows -> V {
        try transform(&data)
    }

    /// Appends the bytes of `newData` to the buffer.
    public mutating func append(_ newData: Data) {
        data.append(newData)
    }

    /// Appends the contents of an unsafe buffer pointer to the buffer.
    public mutating func append<SourceType>(_ buffer: UnsafeBufferPointer<SourceType>) {
        data.append(buffer)
    }

    /// Appends a sequence of bytes to the buffer.
    public mutating func append(contentsOf bytes: [UInt8]) {
        data.append(contentsOf: bytes)
    }

    /// Appends an arbitrary `Sequence` of bytes to the buffer.
    public mutating func append<S: Sequence<UInt8>>(contentsOf elements: S) {
        data.append(contentsOf: elements)
    }

}
