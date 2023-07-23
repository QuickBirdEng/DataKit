//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension UnidirectionalConversion where Source == Target {
    public static var unchanged: Self { .init { $0 } }
}

extension BidirectionalConversion where Source == Target {
    public static var unchanged: Self { .init(forward: .unchanged, backward: .unchanged) }
}
