// FormatBuilder+ReadWrite.swift

import Foundation

/// Result-builder typealias for combined read+write formats — the type of `@FormatBuilder`
/// on ``ReadWritable``.
public typealias ReadWriteFormatBuilder<Root: ReadWritable> = FormatBuilder<Root, ReadWriteFormat<Root>>

extension FormatBuilder where Root: ReadWritable, Format == ReadWriteFormat<Root> {

    /// Any value that conforms to *both* ``ReadableProperty`` and ``WritableProperty`` (e.g.
    /// ``Property``, ``Scope``) participates in a read+write builder.
    public static func buildExpression<V: ReadableProperty & WritableProperty>(_ expression: V) -> Format where V.Root == Format.Root {
        .init(
            read: ReadFormatBuilder.buildExpression(expression),
            write: WriteFormatBuilder.buildExpression(expression)
        )
    }

    /// A ``ReadWritable & Equatable`` literal is *asserted* on read and *emitted* on write —
    /// the natural way to express a magic number that must round-trip identically.
    public static func buildExpression<V: ReadWritable & Equatable>(_ expression: V) -> Format {
        .init(
            read: ReadFormatBuilder.buildExpression(expression),
            write: WriteFormatBuilder.buildExpression(expression)
        )
    }

    /// Bare key-path syntax (`\.field`) lifts to ``Property``.
    public static func buildExpression<Value: ReadWritable>(_ expression: KeyPath<Root, Value>) -> Format {
        .init(
            read: ReadFormatBuilder.buildExpression(expression),
            write: WriteFormatBuilder.buildExpression(expression)
        )
    }

    /// A bare ``Checksum`` value verifies on read and computes on write, always in
    /// big-endian.
    public static func buildExpression<C: Checksum>(_ expression: C) -> Format where C.Value: ReadWritable {
        .init(
            read: ReadFormatBuilder.buildExpression(expression),
            write: WriteFormatBuilder.buildExpression(expression)
        )
    }

    /// A sequence of `ReadWritable & Equatable` literals is asserted/emitted in order.
    public static func buildExpression<S: Sequence>(_ expression: S) -> Format where S.Element: ReadWritable & Equatable {
        .init(expression.map(buildExpression))
    }

}
