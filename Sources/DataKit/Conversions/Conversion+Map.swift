//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.07.23.
//

extension UnidirectionalConversion where Target: Sequence {

    public func map<NewTarget: RangeReplaceableCollection>(
        to target: NewTarget.Type = NewTarget.self,
        _ make: UnidirectionalConversion<Target.Element, NewTarget.Element>.Make
    ) -> Appended<NewTarget> {
        let conversion = UnidirectionalConversion<Target.Element, NewTarget.Element>.make(make)
        return appending { value in
            try .init(
                value.map {
                    try conversion.convert($0)
                }
            )
        }
    }

}

extension BidirectionalConversion where Target: RangeReplaceableCollection {

    public func map<NewTarget: RangeReplaceableCollection>(
        to target: NewTarget.Type = NewTarget.self,
        _ make: BidirectionalConversion<Target.Element, NewTarget.Element>.Make
    ) -> Appended<NewTarget> {
        let conversion = BidirectionalConversion<Target.Element, NewTarget.Element>.make(make)
        return appending {
            $0.map { _ in conversion.forwardConversion }
        } backward: {
            $0.map { _ in conversion.backwardConversion }
        }
    }

}
