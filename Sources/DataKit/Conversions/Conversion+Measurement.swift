//
//  File.swift
//  
//
//  Created by Paul Kraft on 25.07.23.
//

extension Conversion {

    public func converted<UnitType: Dimension>(
        to unit: UnitType
    ) -> Appended<Double> where Target == Measurement<UnitType> {
        appending { $0.converted(to: unit).value }
    }

    public func converted<UnitType: Dimension>(
        to unit: UnitType
    ) -> Appended<Measurement<UnitType>> where Target == Double {
        appending { .init(value: $0, unit: unit) }
    }

}

extension ReversibleConversion {

    public func converted<UnitType: Dimension>(
        to unit: UnitType
    ) -> Appended<Double> where Target == Measurement<UnitType> {
        appending {
            $0.converted(to: unit)
        } revert: {
            $0.converted(to: unit)
        }
    }

    public func converted<UnitType: Dimension>(
        to unit: UnitType
    ) -> Appended<Measurement<UnitType>> where Target == Double {
        appending {
            $0.converted(to: unit)
        } revert: {
            $0.converted(to: unit)
        }
    }

}
