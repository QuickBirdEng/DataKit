//
//  File.swift
//  
//
//  Created by Paul Kraft on 25.07.23.
//

extension UnidirectionalConversion {

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

extension BidirectionalConversion {

    public func converted<UnitType: Dimension>(
        to unit: UnitType
    ) -> Appended<Double> where Target == Measurement<UnitType> {
        appending {
            $0.converted(to: unit)
        } backward: {
            $0.converted(to: unit)
        }
    }

    public func converted<UnitType: Dimension>(
        to unit: UnitType
    ) -> Appended<Measurement<UnitType>> where Target == Double {
        appending {
            $0.converted(to: unit)
        } backward: {
            $0.converted(to: unit)
        }
    }

}
