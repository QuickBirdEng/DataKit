//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.07.23.
//

extension Conversion where Target: Sequence {

    public func map<NewTarget: RangeReplaceableCollection>(
        to target: NewTarget.Type = NewTarget.self,
        _ make: Conversion<Target.Element, NewTarget.Element>.Make
    ) -> Appended<NewTarget> {
        let conversion = Conversion<Target.Element, NewTarget.Element>.make(make)
        return appending { value in
            try .init(
                value.map {
                    try conversion.convert($0)
                }
            )
        }
    }

}

extension ReversibleConversion where Target: RangeReplaceableCollection {

    public func map<NewTarget: RangeReplaceableCollection>(
        to target: NewTarget.Type = NewTarget.self,
        _ make: ReversibleConversion<Target.Element, NewTarget.Element>.Make
    ) -> Appended<NewTarget> {
        let conversion = ReversibleConversion<Target.Element, NewTarget.Element>.make(make)
        return appending {
            $0.map { _ in conversion.conversion }
        } revert: {
            $0.map { _ in conversion.reversion }
        }
    }

}
