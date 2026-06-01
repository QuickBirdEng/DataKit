// Conversion.swift

import Foundation

/// A reusable, composable one-way value transform used by ``Convert`` and
/// ``Property/conversion(_:)``.
///
/// `Conversion` is the composable "I want this in-memory value to ride the wire as a
/// different type" primitive. You rarely create a `Conversion` directly — instead you
/// describe one with the ``make(_:)`` DSL:
///
/// ```swift
/// Convert(\.fileSize) { $0.exactly(UInt32.self) }
/// ```
///
/// The closure receives an identity ``Conversion`` (from `Source` to itself) and returns a
/// `Conversion` from `Source` to whatever type the wire expects, built up by chaining
/// methods like ``cast(_:from:)``, ``exactly(_:from:)``, ``clamped(_:from:)``,
/// ``encoded(_:allowLossyConversion:)``, ``prefixCount(_:)``, ``dynamicCount``, and
/// ``converted(to:)``.
///
/// For ``ReadWritable`` round-trips, use ``ReversibleConversion`` instead — it bundles a
/// pair of inverse transforms in one value.
public struct Conversion<Source, Target>: Sendable {

    // MARK: Stored Properties

    internal let _convert: @Sendable (Source) throws -> Target

    // MARK: Initialization

    internal init(_ convert: @escaping @Sendable (Source) throws -> Target) {
        self._convert = convert
    }

    // MARK: Methods

    /// Applies the conversion to `source`.
    ///
    /// - Throws: Any error raised by the underlying transform (typically
    ///   ``ConversionError`` for value-domain failures).
    public func convert(_ source: Source) throws -> Target {
        try _convert(source)
    }

}

extension Conversion {

    /// The builder-closure signature consumed by ``make(_:)``: receives an identity
    /// conversion and returns the composed result.
    public typealias Make = (Conversion<Source, Source>) -> Conversion<Source, Target>

    /// Builds a `Conversion` by chaining operators off an identity conversion.
    public static func make(_ make: Make) -> Self {
        make(.init { $0 })
    }

}

extension Conversion {

    /// The type produced by ``appending(_:)-fdyu``.
    public typealias Appended<NewTarget> = Conversion<Source, NewTarget>

    /// Composes this conversion with a closure that transforms the target value further.
    public func appending<NewTarget>(
        _ transform: @escaping @Sendable (Target) throws -> NewTarget
    ) -> Appended<NewTarget> {
        .init { try transform(convert($0)) }
    }

    /// Composes this conversion with another `Conversion`.
    public func appending<NewTarget>(
        _ conversion: Conversion<Target, NewTarget>
    ) -> Appended<NewTarget> {
        appending { try conversion.convert($0) }
    }

}
