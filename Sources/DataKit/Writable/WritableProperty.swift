// WritableProperty.swift

import Foundation

/// A ``FormatProperty`` that can encode a value of `Root` into a ``WriteContainer``.
public protocol WritableProperty<Root>: FormatProperty where Root: Writable {

    /// Appends bytes derived from `root` to `container`.
    ///
    /// - Throws: Any encoding error, including ``ConversionError``.
    func write(to container: inout WriteContainer, using root: Root) throws
}

/// A type-erased write format produced by a `@WriteBuilder` block.
///
/// Most users encounter `WriteFormat` only as the return type of `static var writeFormat`.
/// The `init(write:)` initializer is an escape hatch for advanced users who want to drop
/// down to imperative writing.
public struct WriteFormat<Root: Writable>: WritableProperty {

    // MARK: Stored Properties

    private let _write: (inout WriteContainer, Root) throws -> Void

    // MARK: Initialization

    /// Wraps an imperative write closure as a `WriteFormat`.
    public init(write: @escaping (inout WriteContainer, Root) throws -> Void) {
        self._write = write
    }

    // MARK: Methods

    public func write(to container: inout WriteContainer, using root: Root) throws {
        try _write(&container, root)
    }

}

extension WriteFormat: FormatType {

    /// Sequentially composes multiple `WriteFormat`s into one.
    public init(_ multiple: [WriteFormat<Root>]) {
        self.init { container, root in
            for format in multiple {
                try format.write(to: &container, using: root)
            }
        }
    }

}

