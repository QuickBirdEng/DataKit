// Conversion+Cast.swift

import Foundation

// Lossy numeric conversion operators (`init(_:)` semantics).
//
// Use ``Conversion/cast(_:from:)-...`` when you accept potential loss of precision or range
// (e.g. `Double → Float`, `UInt64 → UInt32`). For lossless-only conversions, use
// ``Conversion/exactly(_:from:)-...`` (throws on overflow); for saturating, use
// ``Conversion/clamped(_:from:)-...``.

extension Conversion where Target: BinaryFloatingPoint {

    /// Casts the current floating-point target to a different floating-point type using
    /// the standard library's `init(_:)`. Lossy.
    public func cast<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { NewTarget($0) }
    }

    /// Casts the current floating-point target to an integer type using `init(_:)`. Truncates.
    public func cast<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { NewTarget($0) }
    }

}

extension Conversion where Target: BinaryInteger {

    /// Casts the current integer target to a floating-point type using `init(_:)`.
    public func cast<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { NewTarget($0) }
    }

    /// Casts the current integer target to a different integer type using `init(_:)`.
    public func cast<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { NewTarget($0) }
    }

}

extension ReversibleConversion where Target: BinaryFloatingPoint {

    /// Reversible cast between two floating-point types.
    public func cast<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } revert: { $0.cast() }
    }

    /// Reversible cast between floating-point and integer. Each direction is lossy.
    public func cast<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } revert: { $0.cast() }
    }

}

extension ReversibleConversion where Target: BinaryInteger {

    /// Reversible cast between integer and floating-point.
    public func cast<NewTarget: BinaryFloatingPoint>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } revert: { $0.cast() }
    }

    /// Reversible cast between two integer types.
    public func cast<NewTarget: BinaryInteger>(
        _ target: NewTarget.Type = NewTarget.self,
        from source: Target.Type = Target.self
    ) -> Appended<NewTarget> {
        appending { $0.cast() } revert: { $0.cast() }
    }

}
