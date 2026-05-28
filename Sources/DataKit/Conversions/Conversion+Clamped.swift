// Conversion+Clamped.swift

import Foundation

extension Conversion where Target: BinaryInteger {

    /// Saturating integer conversion using the standard library's `init(clamping:)`.
    ///
    /// Values outside the target type's representable range are clamped to the nearest
    /// representable value. Non-throwing.
    public func clamped<NewTarget: BinaryInteger>(
        to target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { NewTarget(clamping: $0) }
    }

}

extension ReversibleConversion where Target: BinaryInteger {

    /// Reversible saturating integer conversion. Note: the two directions may not round-trip
    /// for values that were clamped — once clamped, the original value is lost.
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
