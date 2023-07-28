//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension Conversion where Target: BinaryInteger {

    public func clamped<NewTarget: BinaryInteger>(
        to target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { NewTarget(clamping: $0) }
    }

}

extension ReversibleConversion where Target: BinaryInteger {

    public func clamped<NewTarget: BinaryInteger>(
        to target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending {
            $0.clamped()
        } revert: {
            $0.clamped()
        }
    }

}
