//
//  File.swift
//  
//
//  Created by Paul Kraft on 25.06.23.
//

import Foundation

public typealias ReadWriteFormatBuilder<Root: ReadWritable> = FormatBuilder<Root, ReadWriteFormat<Root>>

extension FormatBuilder where Root: ReadWritable, Format == ReadWriteFormat<Root> {

    public static func buildExpression<V: ReadableProperty & WritableProperty>(_ expression: V) -> Format where V.Root == Format.Root {
        .init(
            read: ReadFormatBuilder.buildExpression(expression),
            write: WriteFormatBuilder.buildExpression(expression)
        )
    }

    public static func buildExpression<V: ReadWritable & Equatable>(_ expression: V) -> Format {
        .init(
            read: ReadFormatBuilder.buildExpression(expression),
            write: WriteFormatBuilder.buildExpression(expression)
        )
    }

    public static func buildExpression<Value: ReadWritable>(_ expression: KeyPath<Root, Value>) -> Format {
        .init(
            read: ReadFormatBuilder.buildExpression(expression),
            write: WriteFormatBuilder.buildExpression(expression)
        )
    }

    public static func buildExpression<C: Checksum>(_ expression: C) -> Format where C.Value: ReadWritable {
        .init(
            read: ReadFormatBuilder.buildExpression(expression),
            write: WriteFormatBuilder.buildExpression(expression)
        )
    }

    public static func buildExpression<S: Sequence>(_ expression: S) -> Format where S.Element: ReadWritable & Equatable {
        .init(expression.map(buildExpression))
    }

}
