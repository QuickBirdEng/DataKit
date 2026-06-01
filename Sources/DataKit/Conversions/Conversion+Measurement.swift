// Conversion+Measurement.swift

extension Conversion {

    /// Projects a `Measurement<UnitType>` target onto the scalar value in `unit`.
    public func converted<UnitType: Dimension & Sendable>(
        to unit: UnitType
    ) -> Appended<Double> where Target == Measurement<UnitType> {
        appending { $0.converted(to: unit).value }
    }

    /// Lifts a `Double` target into a `Measurement<UnitType>` with the given unit.
    public func converted<UnitType: Dimension & Sendable>(
        to unit: UnitType
    ) -> Appended<Measurement<UnitType>> where Target == Double {
        appending { .init(value: $0, unit: unit) }
    }

}

extension ReversibleConversion {

    /// Reversible projection between `Measurement<UnitType>` and `Double`.
    public func converted<UnitType: Dimension & Sendable>(
        to unit: UnitType
    ) -> Appended<Double> where Target == Measurement<UnitType> {
        appending {
            $0.converted(to: unit)
        } revert: {
            $0.converted(to: unit)
        }
    }

    /// Reversible projection between `Double` and `Measurement<UnitType>`.
    public func converted<UnitType: Dimension & Sendable>(
        to unit: UnitType
    ) -> Appended<Measurement<UnitType>> where Target == Double {
        appending {
            $0.converted(to: unit)
        } revert: {
            $0.converted(to: unit)
        }
    }

}
