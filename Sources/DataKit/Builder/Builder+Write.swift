//
//  File.swift
//  
//
//  Created by Paul Kraft on 25.06.23.
//

import Foundation

public typealias WriteFormatBuilder<Root: Writable> = FormatBuilder<Root, WriteFormat<Root>>

extension FormatBuilder where Root: Writable, Format == WriteFormat<Root> {

    public static func buildExpression<V: WritableProperty>(_ expression: V) -> Format where V.Root == Format.Root {
        .init(write: expression.write)
    }

    public static func buildExpression<V: Writable>(_ expression: V) -> Format {
        .init { container, _ in
            try expression.write(to: &container)
        }
    }

    public static func buildExpression<S: Sequence>(_ expression: S) -> Format where S.Element: Writable {
        .init(expression.map(buildExpression))
    }

}
