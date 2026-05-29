// Sendable.swift
//
// The `@unchecked Sendable` conformances below all share a single reason: each type stores a
// value the compiler cannot statically prove `Sendable`, yet the type is immutable after
// construction and has no method that mutates shared state, so concurrent use is sound.
//
// 1. **`Any`-storing types.** `ReadContainer`, `WriteContainer`, `ReadContext`, and
//    `EnvironmentValues` carry untyped dictionaries (for environment propagation and for
//    the keyed `ReadContext` scratchpad). The boxed values cannot be proven `Sendable`.
//
// 2. **Types storing closures over un-`Sendable`-constrained generics.** `Conversion`,
//    `ReversibleConversion`, and `DataBuilder.Component` store transform closures over
//    generic `Source`/`Target`/`Element` parameters that are not constrained to `Sendable`.
//    Making the closures `@Sendable` would require propagating `Sendable` bounds through
//    every conversion operator and builder expression — a wide breaking change deferred to a
//    future major version.
//
// Conformances that *can* be checked (value types whose stored closures are `@Sendable` and
// whose other fields are `Sendable`) live inline in their own source files — see `Using`,
// `Environment`, `EnvironmentProperty`, `Convert`, `Custom`, `Scope`, etc.

import Foundation

// MARK: - Containers (Any-storing)

extension ReadContainer: @unchecked Sendable {}
extension WriteContainer: @unchecked Sendable {}
extension ReadContext: @unchecked Sendable {}

// MARK: - Environment (Any-storing)

extension EnvironmentValues: @unchecked Sendable {}

// MARK: - Conversions (closures over un-Sendable-constrained generics)

extension Conversion: @unchecked Sendable {}
extension ReversibleConversion: @unchecked Sendable {}

// MARK: - Result-builder accumulator (closure over un-Sendable-constrained generic)

extension DataBuilder.Component: @unchecked Sendable {}
