
import Foundation

@resultBuilder
public enum DataBuilder {

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

    public static func buildExpression<I: FixedWidthInteger>(_ expression: I) -> Component {
        Component { data in
            withUnsafeBytes(of: expression.bigEndian) {
                data.append(contentsOf: $0)
            }
        }
    }

    public static func buildExpression<F: FixedWidthFloatingPoint>(_ expression: F) -> Component {
        buildExpression(expression.bitPattern)
    }

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

    public static func buildExpression<C: Checksum>(_ expression: C) -> Component {
        Component { data in
            let value = expression.calculate(for: data)
            buildExpression(value).append(&data)
        }
    }

}
