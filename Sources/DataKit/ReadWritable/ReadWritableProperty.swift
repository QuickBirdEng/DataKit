// ReadWritableProperty.swift

import Foundation

/// A combined read+write format produced by a `@FormatBuilder` block.
///
/// `ReadWriteFormat` is what you return from `static var format` on a ``ReadWritable``
/// type. Internally it carries a `ReadFormat<Root>` and a `WriteFormat<Root>` and delegates
/// to them; the framework synthesizes ``Readable/readFormat`` and ``Writable/writeFormat``
/// by projecting onto these underlying formats.
public struct ReadWriteFormat<Root: ReadWritable>: FormatType, ReadableProperty, WritableProperty {

    // MARK: Stored Properties

    private let readFormat: ReadFormat<Root>
    private let writeFormat: WriteFormat<Root>

    // MARK: Initialization

    /// Pairs an existing read format with a write format. The two are expected to be
    /// inverses — their bytes must round-trip identically.
    public init(read: ReadFormat<Root>, write: WriteFormat<Root>) {
        self.readFormat = read
        self.writeFormat = write
    }

    /// Sequentially composes multiple `ReadWriteFormat`s into one.
    public init(_ multiple: [ReadWriteFormat<Root>]) {
        self.init(
            read: .init(multiple.map(\.readFormat)),
            write: .init(multiple.map(\.writeFormat))
        )
    }

    // MARK: Methods

    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try readFormat.read(from: &container, context: &context)
    }

    public func write(to container: inout WriteContainer, using root: Root) throws {
        try writeFormat.write(to: &container, using: root)
    }

}

