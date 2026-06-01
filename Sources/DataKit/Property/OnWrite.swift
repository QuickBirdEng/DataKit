// OnWrite.swift

import Foundation

/// Lifts a write-only format into a ``ReadWritable`` context. The format runs on encode and
/// is a no-op on decode.
///
/// Use this for fields you want to emit but do not need to parse back out — e.g. a magic
/// number that the read side handles via another mechanism, or padding bytes.
public struct OnWrite<Root: ReadWritable>: ReadableProperty, WritableProperty {

    // MARK: Stored Properties

    private let format: WriteFormat<Root>

    // MARK: Initialization

    public init(@WriteFormatBuilder<Root> format: () -> WriteFormat<Root>) {
        self.format = format()
    }

    // MARK: Methods

    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {}

    public func write(to container: inout WriteContainer, using root: Root) throws {
        try format.write(to: &container, using: root)
    }

}

extension OnWrite: Sendable {}
