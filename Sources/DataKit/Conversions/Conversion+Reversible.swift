// Conversion+Reversible.swift

import Foundation

/// A two-way value transform used inside ``Convert`` for ``ReadWritable`` roots.
///
/// `ReversibleConversion` bundles a forward (`convert`) and reverse (`revert`) closure that
/// are expected to be inverses. Most ``Conversion`` operators have a reversible counterpart;
/// the operator chain inside ``make(_:)`` keeps both directions in sync.
///
/// The two `convert(_:)` overloads are disambiguated by their argument label vs. parameter
/// type only — calling `convert(value)` with a `Source` runs the forward direction, calling
/// it with a `Target` runs the reverse. When in doubt, use the explicit
/// ``conversion`` / ``reversion`` projections.
public struct ReversibleConversion<Source, Target>: Sendable {

    // MARK: Stored Properties

    private let _convert: @Sendable (Source) throws -> Target
    private let _revert: @Sendable (Target) throws -> Source

    // MARK: Initialization

    private init(
        convert: @escaping @Sendable (Source) throws -> Target,
        revert: @escaping @Sendable (Target) throws -> Source
    ) {
        self._convert = convert
        self._revert = revert
    }

    // MARK: Methods

    /// Runs the forward direction: `Source → Target`.
    public func convert(_ source: Source) throws -> Target {
        try _convert(source)
    }

    /// Runs the reverse direction: `Target → Source`.
    public func convert(_ target: Target) throws -> Source {
        try _revert(target)
    }

}

extension ReversibleConversion {

    // MARK: Nested Types

    /// Builder-closure signature consumed by ``make(_:)``.
    public typealias Make = (ReversibleConversion<Source, Source>) -> ReversibleConversion<Source, Target>

    // MARK: Static Functions

    /// Builds a `ReversibleConversion` by chaining operators off the identity reversible.
    public static func make(_ make: Make) -> Self {
        make(.init { $0 } revert: { $0 })
    }

}

extension ReversibleConversion {

    // MARK: Nested Types

    public typealias Appended<NewTarget> = ReversibleConversion<Source, NewTarget>

    // MARK: Methods

    /// Composes this reversible with paired forward/reverse closures.
    ///
    /// The two closures must be inverses for round-trip correctness.
    public func appending<NewTarget>(
        convert: @escaping @Sendable (Target) throws -> NewTarget,
        revert: @escaping @Sendable (NewTarget) throws -> Target
    ) -> Appended<NewTarget> {
        .init {
            try convert(_convert($0))
        } revert: {
            try _revert(revert($0))
        }
    }

    /// Composes this reversible with a pair of `Conversion` builders for the forward and
    /// reverse directions.
    public func appending<NewTarget>(
        convert: Conversion<Target, NewTarget>.Make,
        revert: Conversion<NewTarget, Target>.Make
    ) -> Appended<NewTarget> {
        appending(
            convert: Conversion.make(convert)._convert,
            revert: Conversion.make(revert)._convert
        )
    }

}

extension ReversibleConversion {

    // MARK: Computed Properties

    /// Projects onto the forward `Conversion`.
    public var conversion: Conversion<Source, Target> {
        .init(_convert)
    }

    /// Projects onto the reverse `Conversion`.
    public var reversion: Conversion<Target, Source> {
        .init(_revert)
    }

    /// Swaps the forward and reverse directions.
    public var inverted: ReversibleConversion<Target, Source> {
        .init(convert: _revert, revert: _convert)
    }

}
