//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

public struct Conversion<Source, Target> {

    // MARK: Stored Properties

    internal let _convert: (Source) throws -> Target

    // MARK: Initialization

    internal init(_ convert: @escaping (Source) throws -> Target) {
        self._convert = convert
    }

    // MARK: Methods

    public func convert(_ source: Source) throws -> Target {
        try _convert(source)
    }

}

extension Conversion {

    public typealias Make = (Conversion<Source, Source>) -> Conversion<Source, Target>

    public static func make(_ make: Make) -> Self {
        make(.init { $0 })
    }

}

extension Conversion {

    public typealias Appended<NewTarget> = Conversion<Source, NewTarget>

    public func appending<NewTarget>(
        _ transform: @escaping (Target) throws -> NewTarget
    ) -> Appended<NewTarget> {
        .init { try transform(convert($0)) }
    }

    public func appending<NewTarget>(
        _ conversion: Conversion<Target, NewTarget>
    ) -> Appended<NewTarget> {
        appending(conversion.convert)
    }

}
