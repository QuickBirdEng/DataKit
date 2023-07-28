//
//  File.swift
//  
//
//  Created by Paul Kraft on 25.07.23.
//

import Foundation

extension Conversion where Target: BinaryFloatingPoint {

    public func cast<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { NewTarget($0) }
    }

    public func cast<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { NewTarget($0) }
    }

}

extension Conversion where Target: BinaryInteger {

    public func cast<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { NewTarget($0) }
    }

    public func cast<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { NewTarget($0) }
    }

}

extension ReversibleConversion where Target: BinaryFloatingPoint {

    public func cast<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } revert: { $0.cast() }
    }

    public func cast<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } revert: { $0.cast() }
    }

}

extension ReversibleConversion where Target: BinaryInteger {

    public func cast<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } revert: { $0.cast() }
    }

    public func cast<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } revert: { $0.cast() }
    }

}
