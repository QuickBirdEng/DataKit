//
//  File.swift
//  
//
//  Created by Paul Kraft on 25.07.23.
//

import Foundation

extension UnidirectionalConversion where Target: BinaryFloatingPoint {

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

extension UnidirectionalConversion where Target: BinaryInteger {

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

extension BidirectionalConversion where Target: BinaryFloatingPoint {

    public func cast<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } backward: { $0.cast() }
    }

    public func cast<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } backward: { $0.cast() }
    }

}

extension BidirectionalConversion where Target: BinaryInteger {

    public func cast<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } backward: { $0.cast() }
    }

    public func cast<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } backward: { $0.cast() }
    }

}
