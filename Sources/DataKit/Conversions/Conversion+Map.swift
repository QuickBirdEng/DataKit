// Conversion+Map.swift

extension Conversion where Target: Sequence & Sendable {

    /// Lifts a per-element `Conversion` to a sequence conversion that produces a
    /// `RangeReplaceableCollection`.
    public func map<NewTarget: RangeReplaceableCollection & Sendable>(
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

extension ReversibleConversion where Target: RangeReplaceableCollection & Sendable {

    /// Two-way variant of ``Conversion/map(to:_:)`` — the per-element conversion must itself
    /// be reversible.
    public func map<NewTarget: RangeReplaceableCollection & Sendable>(
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
