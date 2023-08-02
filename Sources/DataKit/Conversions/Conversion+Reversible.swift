//
//  File.swift
//  
//
//  Created by Paul Kraft on 28.07.23.
//

import Foundation

public struct ReversibleConversion<Source, Target> {

    // MARK: Stored Properties

    private let _convert: (Source) throws -> Target
    private let _revert: (Target) throws -> Source

    // MARK: Initialization

    private init(
        convert: @escaping (Source) throws -> Target,
        revert: @escaping (Target) throws -> Source
    ) {
        self._convert = convert
        self._revert = revert
    }

    // MARK: Methods

    public func convert(_ source: Source) throws -> Target {
        try _convert(source)
    }

    public func convert(_ target: Target) throws -> Source {
        try _revert(target)
    }

}

extension ReversibleConversion {

    // MARK: Nested Types

    public typealias Make = (ReversibleConversion<Source, Source>) -> ReversibleConversion<Source, Target>

    // MARK: Static Functions

    public static func make(_ make: Make) -> Self {
        make(.init { $0 } revert: { $0 })
    }

}

extension ReversibleConversion {

    // MARK: Nested Types

    public typealias Appended<NewTarget> = ReversibleConversion<Source, NewTarget>

    // MARK: Methods

    public func appending<NewTarget>(
        convert: @escaping (Target) throws -> NewTarget,
        revert: @escaping (NewTarget) throws -> Target
    ) -> Appended<NewTarget> {
        .init {
            try convert(_convert($0))
        } revert: {
            try _revert(revert($0))
        }
    }

    public func appending<NewTarget>(
        convert: Conversion<Target, NewTarget>.Make,
        revert: Conversion<NewTarget, Target>.Make
    ) -> Appended<NewTarget> {
        appending(
            convert: Conversion.make(convert)._convert,
            revert: Conversion.make(revert)._convert
        )
    }

}

extension ReversibleConversion {

    // MARK: Computed Properties

    public var conversion: Conversion<Source, Target> {
        .init(_convert)
    }

    public var reversion: Conversion<Target, Source> {
        .init(_revert)
    }

    public var inverted: ReversibleConversion<Target, Source> {
        .init(convert: _revert, revert: _convert)
    }

}
