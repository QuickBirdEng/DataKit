
import Foundation

@resultBuilder
public enum DataBuilder {

    public struct Component {
        fileprivate let append: (inout Data) -> Void
    }

    public static func buildBlock(_ components: Component...) -> Component {
        Component { data in
            for component in components {
                component.append(&data)
            }
        }
    }

    public static func buildExpression(_ expression: UInt8) -> Component {
        Component { $0.append(expression) }
    }

    public static func buildExpression<I: FixedWidthInteger>(_ expression: I) -> Component {
        Component { data in
            withUnsafeBytes(of: expression) {
                data.append(contentsOf: $0)
            }
        }
    }

    public static func buildExpression<R: RawRepresentable>(component: R) -> Component where R.RawValue: FixedWidthInteger {
        buildExpression(component.rawValue)
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

    public static func buildExpression<C: ChecksumAlgorithm>(_ expression: C) -> Component {
        Component { data in
            let checksum = expression.calculate(for: data)
            let component = buildExpression(checksum)
            component.append(&data)
        }
    }

}
