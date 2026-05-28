// Conversion+Exactly.swift

import Foundation

// Throwing numeric conversion operators (`init(exactly:)` semantics).
//
// Use ``Conversion/exactly(_:from:)-...`` when you want overflow / non-representability to
// surface as an error rather than being silently truncated (``Conversion/cast(_:from:)-...``)
// or clamped (``Conversion/clamped(_:from:)-...``).

extension Conversion where Target: BinaryFloatingPoint {

    /// Lossless floating-point → floating-point conversion. Throws ``ConversionError`` if
    /// the value cannot be represented exactly in `NewTarget`.
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

    /// Lossless floating-point → integer conversion. Throws ``ConversionError`` if the
    /// value is non-integral or out of range.
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

    /// Lossless integer → floating-point conversion. Throws ``ConversionError`` if the
    /// value cannot be represented exactly in `NewTarget`.
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

    /// Lossless integer → integer conversion. Throws ``ConversionError`` if the value
    /// would overflow `NewTarget`.
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

    /// Reversible lossless floating-point ↔ floating-point conversion.
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

    /// Reversible lossless floating-point ↔ integer conversion.
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

    /// Reversible lossless integer ↔ floating-point conversion.
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

    /// Reversible lossless integer ↔ integer conversion.
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
