// ReadableProperty.swift

import Foundation

/// A ``FormatProperty`` that can decode bytes from a ``ReadContainer`` into a ``ReadContext``.
public protocol ReadableProperty<Root>: FormatProperty where Root: Readable {

    /// Parses values from `container` and stores them into `context`.
    ///
    /// - Throws: Any decoding error, including ``ReadContainer/LengthExceededError``,
    ///   ``ConversionError``, or ``UnexpectedValueError``.
    func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws
}

/// A type-erased read format produced by a `@ReadBuilder` block.
///
/// Most users encounter `ReadFormat` only as the return type of `static var readFormat`.
/// The `init(read:)` initializer is an escape hatch for advanced users who want to drop
/// down to imperative reading.
public struct ReadFormat<Root: Readable>: ReadableProperty {

    // MARK: Stored Properties

    private let _read: (inout ReadContainer, inout ReadContext<Root>) throws -> Void

    // MARK: Initialization

    /// Wraps an imperative read closure as a `ReadFormat`.
    public init(read: @escaping (inout ReadContainer, inout ReadContext<Root>) throws -> Void) {
        self._read = read
    }

    // MARK: Methods

    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try _read(&container, &context)
    }

}

extension ReadFormat: FormatType {

    /// Sequentially composes multiple `ReadFormat`s into one.
    public init(_ multiple: [ReadFormat<Root>]) {
        self.init { container, context in
            for format in multiple {
                try format.read(from: &container, context: &context)
            }
        }
    }
}

