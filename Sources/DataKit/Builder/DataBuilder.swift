// DataBuilder.swift

import Foundation

/// A simple `@resultBuilder` for assembling raw `Data` values declaratively.
///
/// `DataBuilder` is a standalone, non-throwing helper for cases where you just want to
/// build a binary blob without a full ``Readable``/``Writable`` model — for example, to
/// supply a custom suffix via ``FormatProperty/suffix(_:isRequired:)-...``.
///
/// **Endianness footgun.** Unlike the format DSL — which honors
/// ``EnvironmentValues/endianness`` — `DataBuilder`'s integer and floating-point
/// expressions always encode in **big-endian**. If you need a different byte order, use
/// the format DSL instead.
@resultBuilder
public enum DataBuilder {

    /// An accumulator step. Each `Component` appends to a shared `Data` buffer when applied.
    public struct Component {

        // MARK: Stored Properties

        public let append: (_ to: inout Data) -> Void

        // MARK: Initialization

        public init(append: @escaping (_ to: inout Data) -> Void) {
            self.append = append
        }

    }

    public static func buildBlock(_ components: Component...) -> Component {
        Component { data in
            for component in components {
                component.append(&data)
            }
        }
    }

    /// Integers are encoded **big-endian**, regardless of any surrounding format
    /// environment.
    public static func buildExpression<I: FixedWidthInteger>(_ expression: I) -> Component {
        Component { data in
            withUnsafeBytes(of: expression.bigEndian) {
                data.append(contentsOf: $0)
            }
        }
    }

    /// Floating-point values are encoded via their integer `bitPattern`, **big-endian**.
    public static func buildExpression<F: FixedWidthFloatingPoint>(_ expression: F) -> Component {
        buildExpression(expression.bitPattern)
    }

    /// A `RawRepresentable` whose raw value is a fixed-width integer is lifted to its
    /// integer encoding.
    public static func buildExpression<R: RawRepresentable>(
        _ expression: R
    ) -> Component where R.RawValue: FixedWidthInteger {
        buildExpression(expression.rawValue)
    }

    public static func buildOptional(_ component: Component?) -> Component {
        Component {
            component?.append(&$0)
        }
    }

    public static func buildEither(first component: Component) -> Component {
        component
    }

    public static func buildEither(second component: Component) -> Component {
        component
    }

    public static func buildLimitedAvailability(_ component: Component) -> Component {
        component
    }

    public static func buildFinalResult(_ component: Component) -> Data {
        var data = Data()
        component.append(&data)
        return data
    }

    /// A bare ``Checksum`` value computes its checksum over the buffer accumulated so far
    /// and appends the result (in big-endian).
    public static func buildExpression<C: Checksum>(_ expression: C) -> Component {
        Component { data in
            let value = expression.calculate(for: data)
            buildExpression(value).append(&data)
        }
    }

}
