//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

public struct UnidirectionalConversion<Source, Target> {

    // MARK: Stored Properties

    fileprivate let _convert: (Source) throws -> Target

    // MARK: Initialization

    public init(_ convert: @escaping (Source) throws -> Target) {
        self._convert = convert
    }

    // MARK: Methods

    public func convert(_ source: Source) throws -> Target {
        try _convert(source)
    }

}

public struct BidirectionalConversion<Source, Target> {

    // MARK: Stored Properties

    private let _forward: (Source) throws -> Target
    private let _backward: (Target) throws -> Source

    // MARK: Computed Properties

    public var forwardConversion: UnidirectionalConversion<Source, Target> {
        .init(_forward)
    }

    public var backwardConversion: UnidirectionalConversion<Target, Source> {
        .init(_backward)
    }

    // MARK: Initialization

    public init(
        forward: UnidirectionalConversion<Source, Target>,
        backward: UnidirectionalConversion<Target, Source>
    ) {
        self.init(forward: forward._convert, backward: backward._convert)
    }

    public init(
        forward: @escaping (Source) throws -> Target,
        backward: @escaping (Target) throws -> Source
    ) {
        self._forward = forward
        self._backward = backward
    }

    // MARK: Methods

    public func inverted() -> BidirectionalConversion<Target, Source> {
        .init(forward: _backward, backward: _forward)
    }

    public func convert(_ source: Source) throws -> Target {
        try _forward(source)
    }

    public func convert(_ target: Target) throws -> Source {
        try _backward(target)
    }

}
