//
//  File.swift
//  
//
//  Created by Paul Kraft on 25.06.23.
//

import Foundation

public typealias ReadFormatBuilder<Root: Readable> = FormatBuilder<Root, ReadFormat<Root>>

extension FormatBuilder where Root: Readable, Format == ReadFormat<Root> {

    public static func buildExpression<V: Readable & Equatable>(_ expression: V) -> Format {
        .init { container, _ in
            let value = try V(from: &container)
            if value != expression {
                throw UnexpectedValueError(expectedValue: expression, actualValue: value)
            }
        }
    }

    public static func buildExpression<V: ReadableProperty>(_ expression: V) -> Format where V.Root == Root {
        .init(read: expression.read)
    }

    public static func buildExpression<S: Sequence>(_ expression: S) -> Format where S.Element: Readable & Equatable {
        .init(expression.map(buildExpression))
    }

}
