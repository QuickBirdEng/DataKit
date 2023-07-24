//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension UnidirectionalConversion {

    public static func keyPath(_ keyPath: KeyPath<Source, Target>) -> Self {
        .init { $0[keyPath: keyPath] }
    }

}

extension BidirectionalConversion {

    public static func keyPaths(_ forward: KeyPath<Source, Target>, _ backward: KeyPath<Target, Source>) -> Self {
        .init(forward: .keyPath(forward), backward: .keyPath(backward))
    }

    public static func keyPath(_ keyPath: KeyPath<Source, Target>) -> Self where Source == Target {
        .init(forward: .keyPath(keyPath), backward: .keyPath(keyPath))
    }

}
