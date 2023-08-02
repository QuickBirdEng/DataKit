//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension Conversion where Target: BinaryFloatingPoint {

    public func exactly<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { value in
            guard let result = NewTarget(exactly: value) else {
                throw ConversionError(source: value, targetType: NewTarget.self)
            }
            return result

        }
    }

    public func exactly<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { value in
            guard let result = NewTarget(exactly: value) else {
                throw ConversionError(source: value, targetType: NewTarget.self)
            }
            return result

        }
    }

}

extension Conversion where Target: BinaryInteger {

    public func exactly<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { value in
            guard let result = NewTarget(exactly: value) else {
                throw ConversionError(source: value, targetType: NewTarget.self)
            }
            return result

        }
    }

    public func exactly<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { value in
            guard let result = NewTarget(exactly: value) else {
                throw ConversionError(source: value, targetType: NewTarget.self)
            }
            return result

        }
    }

}

extension ReversibleConversion where Target: BinaryFloatingPoint {

    public func exactly<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending {
            $0.exactly()
        } revert: {
            $0.exactly()
        }
    }

    public func exactly<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending {
            $0.exactly()
        } revert: {
            $0.exactly()
        }
    }

}

extension ReversibleConversion where Target: BinaryInteger {

    public func exactly<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending {
            $0.exactly()
        } revert: {
            $0.exactly()
        }
    }

    public func exactly<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending {
            $0.exactly()
        } revert: {
            $0.exactly()
        }
    }

}
