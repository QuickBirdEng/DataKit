//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension UnidirectionalConversion {

    public static func exactly(from source: Source.Type = Source.self, to target: Target.Type = Target.self) -> Self where Source: BinaryFloatingPoint, Target: BinaryFloatingPoint {
        .init { source in
            guard let target = Target(exactly: source) else {
                throw ConversionError(source: source, targetType: Target.self)
            }
            return target
        }
    }

    public static func exactly(from source: Source.Type = Source.self, to target: Target.Type = Target.self) -> Self where Source: BinaryFloatingPoint, Target: BinaryInteger {
        .init { source in
            guard let target = Target(exactly: source) else {
                throw ConversionError(source: source, targetType: Target.self)
            }
            return target
        }
    }

    public static func exactly(from source: Source.Type = Source.self, to target: Target.Type = Target.self) -> Self where Source: BinaryInteger, Target: BinaryFloatingPoint {
        .init { source in
            guard let target = Target(exactly: source) else {
                throw ConversionError(source: source, targetType: Target.self)
            }
            return target
        }
    }

    public static func exactly(from source: Source.Type = Source.self, to target: Target.Type = Target.self) -> Self where Source: BinaryInteger, Target: BinaryInteger {
        .init { source in
            guard let target = Target(exactly: source) else {
                throw ConversionError(source: source, targetType: Target.self)
            }
            return target
        }
    }

}

extension BidirectionalConversion {

    public static func exactly(_ target: Target.Type, from source: Source.Type = Source.self) -> Self where Source: BinaryFloatingPoint, Target: BinaryFloatingPoint {
        .init(forward: .exactly(), backward: .exactly())
    }

    public static func exactly(_ target: Target.Type, from source: Source.Type = Source.self) -> Self where Source: BinaryFloatingPoint, Target: BinaryInteger {
        .init(forward: .exactly(), backward: .exactly())
    }

    public static func exactly(_ target: Target.Type, from source: Source.Type = Source.self) -> Self where Source: BinaryInteger, Target: BinaryFloatingPoint {
        .init(forward: .exactly(), backward: .exactly())
    }

    public static func exactly(_ target: Target.Type, from source: Source.Type = Source.self) -> Self where Source: BinaryInteger, Target: BinaryInteger {
        .init(forward: .exactly(), backward: .exactly())
    }

}
