//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension UnidirectionalConversion where Target: BinaryInteger {

    public func clamped<NewTarget: BinaryInteger>(
        to target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { NewTarget(clamping: $0) }
    }

}

extension BidirectionalConversion where Target: BinaryInteger {

    public func clamped<NewTarget: BinaryInteger>(
        to target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending {
            $0.clamped()
        } backward: {
            $0.clamped()
        }
    }

}
