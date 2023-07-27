//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

public struct UnidirectionalConversion<Source, Target> {

    // MARK: Nested Types

    public typealias Make = (UnidirectionalConversion<Source, Source>) -> UnidirectionalConversion<Source, Target>
    public typealias Appended<NewTarget> = UnidirectionalConversion<Source, NewTarget>

    // MARK: Static Functions

    public static func make(_ make: Make) -> Self {
        make(UnidirectionalConversion<Source, Source> { $0 })
    }

    // MARK: Stored Properties

    public let convert: (Source) throws -> Target

    // MARK: Initialization

    internal init(_ convert: @escaping (Source) throws -> Target) {
        self.convert = convert
    }

    // MARK: Methods

    public func appending<NewTarget>(
        _ transform: @escaping (Target) throws -> NewTarget
    ) -> Appended<NewTarget> {
        .init { try transform(convert($0)) }
    }

    public func appending<NewTarget>(
        _ conversion: UnidirectionalConversion<Target, NewTarget>
    ) -> Appended<NewTarget> {
        appending(conversion.convert)
    }

}

public struct BidirectionalConversion<Source, Target> {

    // MARK: Nested Types

    public typealias Make = (BidirectionalConversion<Source, Source>) -> BidirectionalConversion<Source, Target>
    public typealias Appended<NewTarget> = BidirectionalConversion<Source, NewTarget>

    // MARK: Static Properties

    public static func make(_ make: Make) -> Self {
        make(BidirectionalConversion<Source, Source> { $0 } backward: { $0 })
    }
    // MARK: Stored Properties

    fileprivate let _forward: (Source) throws -> Target
    fileprivate let _backward: (Target) throws -> Source

    // MARK: Computed Properties

    public var forwardConversion: UnidirectionalConversion<Source, Target> {
        .init(_forward)
    }

    public var backwardConversion: UnidirectionalConversion<Target, Source> {
        .init(_backward)
    }

    // MARK: Initialization

    private init(
        forward: @escaping (Source) throws -> Target,
        backward: @escaping (Target) throws -> Source
    ) {
        self._forward = forward
        self._backward = backward
    }

    // MARK: Methods

    public func reversed() -> BidirectionalConversion<Target, Source> {
        .init(forward: _backward, backward: _forward)
    }

    public func convert(_ source: Source) throws -> Target {
        try _forward(source)
    }

    public func convert(_ target: Target) throws -> Source {
        try _backward(target)
    }

    public func appending<NewTarget>(
        forward: @escaping (Target) throws -> NewTarget,
        backward: @escaping (NewTarget) throws -> Target
    ) -> Appended<NewTarget> {
        .init {
            try forward(_forward($0))
        } backward: {
            try _backward(backward($0))
        }
    }

    public func appending<NewTarget>(
        forward: UnidirectionalConversion<Target, NewTarget>.Make,
        backward: UnidirectionalConversion<NewTarget, Target>.Make
    ) -> Appended<NewTarget> {
        let forwardConversion = UnidirectionalConversion<Target, NewTarget>.make(forward)
        let backwardConversion = UnidirectionalConversion<NewTarget, Target>.make(backward)

        return appending(
            forward: forwardConversion.convert,
            backward: backwardConversion.convert
        )
    }

}
