// OnRead.swift

import Foundation

/// Lifts a read-only format into a ``ReadWritable`` context. The format runs on decode and
/// is a no-op on encode.
///
/// Use this for fields you want to parse but do not need to write back out — e.g. asserted
/// constants whose bytes are produced separately, or padding that you want to skip without
/// emitting on write.
public struct OnRead<Root: ReadWritable>: ReadableProperty, WritableProperty {

    // MARK: Stored Properties

    private let format: ReadFormat<Root>

    // MARK: Initialization

    public init(@ReadFormatBuilder<Root> format: () -> ReadFormat<Root>) {
        self.format = format()
    }

    // MARK: Methods

    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try format.read(from: &container, context: &context)
    }

    public func write(to container: inout WriteContainer, using root: Root) throws {}

}

extension OnRead: Sendable {}
