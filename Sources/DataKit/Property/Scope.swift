// Scope.swift

import Foundation

/// Restricts the data view of an inner format to a sub-range of the surrounding container.
///
/// `Scope` is the building block for protocols where the boundaries of "the message" matter
/// independently from the boundaries of any one field. Two common uses:
///
/// - **Bounded checksum coverage.** A ``ChecksumProperty`` inside a `Scope` covers exactly
///   the bytes consumed inside that scope, not the entire parent container. Use `endInset`
///   to reserve trailing bytes (typically the checksum's own bytes) so they are not part
///   of the verified range.
/// - **Excluding a prefix/suffix from a covered region.** A constant frame prefix can be
///   read outside the scope and therefore omitted from the checksum domain.
///
/// On decode, the inner format runs against a sub-container that ends `endInset` bytes
/// before the parent's current end. The outer cursor is advanced by however many bytes
/// the inner format actually consumed. On encode, the inner format runs into a fresh
/// `WriteContainer` and the resulting bytes are appended to the outer container — there is
/// no write-side `endInset`, because reserving trailing bytes is meaningful only for reads.
public struct Scope<Format: FormatProperty>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    private let endInset: Int
    private let format: Format

    // MARK: Initialization

    /// Creates a read-only scope.
    ///
    /// - Parameters:
    ///   - endInset: Number of trailing bytes to leave outside the scope (e.g. the size of
    ///     a checksum that follows the covered range). Defaults to `0`.
    public init<Root: Readable>(
        endInset: Int = 0,
        @FormatBuilder<Root, Format> format: () -> Format
    ) where Format == ReadFormat<Root> {
        self.endInset = endInset
        self.format = format()
    }

    /// Creates a write-only scope. The write-side has no `endInset` because trailing-byte
    /// reservation is not meaningful when serializing.
    public init<Root: Writable>(
        @FormatBuilder<Root, Format> format: () -> Format
    ) where Format == WriteFormat<Root> {
        self.endInset = 0
        self.format = format()
    }

    /// Creates a read+write scope.
    ///
    /// - Parameters:
    ///   - endInset: Read-side: number of trailing bytes to leave outside the scope.
    ///     Ignored on write.
    public init<Root: ReadWritable>(
        endInset: Int = 0,
        @FormatBuilder<Root, Format> format: () -> Format
    ) where Format == ReadWriteFormat<Root> {
        self.endInset = endInset
        self.format = format()
    }

}

extension Scope: ReadableProperty where Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        guard let endIndex = container.data.index(container.data.endIndex, offsetBy: -endInset, limitedBy: container.index) else {
            throw ReadContainer.LengthExceededError()
        }
        var nestedContainer = ReadContainer(data: container.remainingData.prefix(upTo: endIndex), environment: container.environment)
        try format.read(from: &nestedContainer, context: &context)
        let distance = nestedContainer.data.distance(from: nestedContainer.data.startIndex, to: nestedContainer.index)
        container.index = container.data.index(container.index, offsetBy: distance)
    }
}

extension Scope: WritableProperty where Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        var nestedContainer = WriteContainer(environment: container.environment)
        try format.write(to: &nestedContainer, using: root)
        container.append(nestedContainer.data)
    }
}

extension Scope: Sendable where Format: Sendable {}
