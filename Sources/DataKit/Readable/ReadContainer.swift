// ReadContainer.swift

import Foundation

/// The mutable read cursor passed through the format walk.
///
/// A `ReadContainer` carries the full source `data`, the current cursor `index`, and the
/// active `EnvironmentValues`. Format properties advance the cursor via ``consume(_:)``
/// or by recursively running nested format readers.
///
/// A nested `Scope` runs the inner format against a *sub-container* whose `data` covers
/// only the scoped sub-range. This is what makes `consumedData` and `remainingData`
/// correctly reflect just the scoped region — important for checksum verification.
public struct ReadContainer {

    // MARK: Nested Types

    /// Thrown by ``consume(_:)`` when the requested byte count would read past the end of
    /// the (sub-)container.
    public struct LengthExceededError: Error, Sendable {}

    // MARK: Stored Properties

    /// The full byte buffer this container is reading from. For a `Scope` sub-container,
    /// this is the slice covering only the scoped region.
    public let data: Data

    /// The cursor position. Bytes before `index` have been consumed by the format walk so
    /// far; bytes from `index` onward are still to be read.
    public var index: Data.Index

    /// The active environment (endianness, suffix terminator, etc.). Modifiers such as
    /// `.endianness(.big)` create a child container with a transformed environment, then
    /// restore the previous environment afterwards.
    public var environment: EnvironmentValues

    // MARK: Computed Properties

    /// Bytes from the start of `data` up to (but not including) `index` — i.e. everything
    /// that has been consumed so far in this container. Used as the input range for
    /// `ChecksumProperty`.
    public var consumedData: Data {
        data.prefix(upTo: index)
    }

    /// Bytes from `index` to the end of `data` — i.e. what is still left to read.
    public var remainingData: Data {
        data.suffix(from: index)
    }

    // MARK: Initialization

    /// Creates a container over `data` with an initial cursor and environment.
    ///
    /// - Parameters:
    ///   - data: The bytes to read.
    ///   - index: The starting cursor. Defaults to `data.startIndex`.
    ///   - environment: The initial environment.
    public init(
        data: Data,
        index: Data.Index? = nil,
        environment: EnvironmentValues
    ) {
        self.data = data
        self.index = index ?? data.startIndex
        self.environment = environment
    }

    // MARK: Methods

    /// Consumes the next `count` bytes from the cursor and returns them as a slice.
    ///
    /// The cursor is advanced past the returned range. If the container has fewer than
    /// `count` bytes remaining, the cursor is left unchanged and an error is thrown.
    ///
    /// - Throws: ``LengthExceededError`` if `count` exceeds the number of bytes remaining.
    public mutating func consume(_ count: Int) throws -> Data {
        guard count <= data.distance(from: index, to: data.endIndex) else {
            throw LengthExceededError()
        }
        let newIndex = data.index(index, offsetBy: count)
        defer { index = newIndex }
        return data[index..<newIndex]
    }

}
