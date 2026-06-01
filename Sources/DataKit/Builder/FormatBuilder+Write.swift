// FormatBuilder+Write.swift

import Foundation

/// Result-builder typealias for write formats — the type of `@WriteBuilder`.
public typealias WriteFormatBuilder<Root: Writable> = FormatBuilder<Root, WriteFormat<Root>>

extension FormatBuilder where Root: Writable, Format == WriteFormat<Root> {

    /// Any ``WritableProperty`` (e.g. ``Property``, ``Convert``, ``Custom``, ``Scope``)
    /// participates in a write builder.
    public static func buildExpression<V: WritableProperty>(_ expression: V) -> Format where V.Root == Format.Root {
        .init { container, root in
            try expression.write(to: &container, using: root)
        }
    }

    /// A ``Writable`` literal in a `@WriteBuilder` block is serialized verbatim — used for
    /// emitting magic numbers, framing bytes, etc.
    public static func buildExpression<V: Writable>(_ expression: V) -> Format {
        .init { container, _ in
            try expression.write(to: &container)
        }
    }

    /// Bare key-path syntax (`\.field`) lifts to ``Property``.
    public static func buildExpression<Value: Writable>(_ expression: KeyPath<Root, Value>) -> Format {
        buildExpression(Property(expression))
    }

    /// A bare ``Checksum`` value in a `@WriteBuilder` block computes the checksum over the
    /// buffer accumulated so far and appends it (always in big-endian). To control the
    /// input range, wrap the relevant section in a ``Scope``.
    public static func buildExpression<C: Checksum & Sendable>(_ expression: C) -> Format where C.Value: Writable {
        buildExpression(
            WriteFormat { container, _ in
                try expression.calculate(for: container.data)
                    .write(to: &container)
            }
            .endianness(.big)
        )
    }

    /// A sequence of ``Writable`` literals is emitted in order.
    public static func buildExpression<S: Sequence>(_ expression: S) -> Format where S.Element: Writable {
        .init(expression.map(buildExpression))
    }

}
