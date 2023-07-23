//
//  File.swift
//  
//
//  Created by Paul Kraft on 25.06.23.
//

import Foundation

@resultBuilder
public enum FormatBuilder<Root, Format: FormatType> where Format.Root == Root {

    // MARK: Expressions

    public static func buildExpression(_ expression: ()) -> Format {
        .init([])
    }

    // MARK: Components

    public static func buildArray(_ components: [Format]) -> Format {
        .init(components)
    }

    public static func buildBlock(_ component: Format) -> Format {
        component
    }

    public static func buildBlock(_ components: Format...) -> Format {
        .init(components)
    }

    public static func buildEither(first component: Format) -> Format {
        component
    }

    public static func buildEither(second component: Format) -> Format {
        component
    }

    public static func buildLimitedAvailability(_ component: Format) -> Format {
        component
    }

    public static func buildOptional(_ component: Format?) -> Format {
        .init(component.map { [$0] } ?? [])
    }

    public static func buildPartialBlock(first: Format) -> Format {
        first
    }

    public static func buildPartialBlock(accumulated: Format, next: Format) -> Format {
        .init([accumulated, next])
    }

}
