//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension UnidirectionalConversion {

    public static func clamped(_ target: Target.Type, from source: Source.Type = Source.self) -> Self where Source: BinaryInteger, Target: BinaryInteger {
        .init { Target(clamping: $0) }
    }

}

extension BidirectionalConversion {

    public static func clamped(_ target: Target.Type, from source: Source.Type = Source.self) -> Self where Source: BinaryInteger, Target: BinaryInteger {
        .init(forward: .clamped(Target.self), backward: .clamped(Source.self))
    }

}
