//
//  File.swift
//  
//
//  Created by Paul Kraft on 25.06.23.
//

import Foundation

public typealias ReadWriteFormatBuilder<Root: ReadWritable> = FormatBuilder<Root, ReadWriteFormat<Root>>

extension FormatBuilder where Root: ReadWritable, Format == ReadWriteFormat<Root> {

    public static func buildExpression<V: ReadWritableProperty>(_ expression: V) -> Format where V.Root == Format.Root {
        .init(read: expression.read, write: expression.write)
    }

    public static func buildExpression<V: ReadWritable & Equatable>(_ expression: V) -> Format {
        .init { container, _ in
            let value = try V(from: &container)
            if value != expression {
                throw UnexpectedValueError(expectedValue: expression, actualValue: value)
            }
        } write: { container, _ in
            try expression.write(to: &container)
        }
    }

    public static func buildExpression<S: Sequence>(_ expression: S) -> Format where S.Element: ReadWritable & Equatable {
        .init(expression.map(buildExpression))
    }

}
