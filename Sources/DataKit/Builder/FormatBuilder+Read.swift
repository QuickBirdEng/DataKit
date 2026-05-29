// FormatBuilder+Read.swift

import Foundation

/// Result-builder typealias for read formats — the type of `@ReadBuilder`.
public typealias ReadFormatBuilder<Root: Readable> = FormatBuilder<Root, ReadFormat<Root>>

extension FormatBuilder where Root: Readable, Format == ReadFormat<Root> {

    /// An `Equatable & Readable` literal in a `@ReadBuilder` block parses the corresponding
    /// bytes and asserts equality with the literal — throwing ``UnexpectedValueError`` on
    /// mismatch. This is how magic-number / frame-prefix assertions are expressed.
    public static func buildExpression<V: Readable & Equatable>(_ expression: V) -> Format {
        .init { container, _ in
            let value = try V(from: &container)
            if value != expression {
                throw UnexpectedValueError(expectedValue: expression, actualValue: value)
            }
        }
    }

    /// A bare ``Checksum`` value in a `@ReadBuilder` block reads and verifies the checksum
    /// bytes (always in big-endian). To control the input range, wrap the relevant section
    /// in a ``Scope``.
    public static func buildExpression<C: Checksum & Sendable>(_ expression: C) -> Format where C.Value: Readable {
        buildExpression(
            ReadFormat { container, _ in
                let verificationData = container.consumedData
                try expression.verify(C.Value(from: &container), for: verificationData)
            }
            .endianness(.big)
        )
    }

    /// Any ``ReadableProperty`` (e.g. ``Property``, ``Convert``, ``Custom``, ``Scope``)
    /// participates in a read builder.
    public static func buildExpression<V: ReadableProperty>(_ expression: V) -> Format where V.Root == Root {
        .init { container, context in
            try expression.read(from: &container, context: &context)
        }
    }

    /// Bare key-path syntax (`\.field`) lifts to ``Property``.
    public static func buildExpression<Value: Readable>(_ expression: KeyPath<Root, Value>) -> Format {
        buildExpression(Property(expression))
    }

    /// A sequence of `Equatable & Readable` literals reads and asserts each element in order
    /// — useful for multi-byte magic-number prefixes.
    public static func buildExpression<S: Sequence>(_ expression: S) -> Format where S.Element: Readable & Equatable {
        .init(expression.map(buildExpression))
    }

}
