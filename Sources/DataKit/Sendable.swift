// Sendable.swift
//
// `Sendable` conformances for DataKit types that cannot be co-located with their
// declarations because of Swift 6's same-file rule. Conformances for value types that
// store `@Sendable` closures or pure-data fields live inline in their own source files.
//
// The remaining `@unchecked Sendable` conformances below fall into two categories:
//
// 1. **Closure-bearing types whose stored closures are not yet `@Sendable`-annotated.**
//    `Using`, `Environment`, `EnvironmentProperty`, `Conversion`, `ReversibleConversion`,
//    and `DataBuilder.Component` carry closures that come from user call sites; making
//    them `@Sendable` would propagate breaking changes through every caller of those
//    types' closure-taking initializers. The structs are immutable, so concurrent use is
//    sound in practice, but tightening this is a future major-version cleanup.
//
// 2. **`Any`-storing types.** `ReadContainer`, `WriteContainer`, `ReadContext`, and
//    `EnvironmentValues` carry untyped dictionaries (for environment propagation and for
//    the keyed `ReadContext` scratchpad). These cannot be statically proven `Sendable`,
//    but they have no mutating methods that race against concurrent use.

import Foundation

// MARK: - Containers

extension ReadContainer: @unchecked Sendable {}
extension WriteContainer: @unchecked Sendable {}
extension ReadContext: @unchecked Sendable {}

// MARK: - Environment

extension EnvironmentValues: @unchecked Sendable {}

// MARK: - Closure-bearing format primitives (future-major-version cleanup)

extension Using: @unchecked Sendable {}
extension Environment: @unchecked Sendable {}
extension EnvironmentProperty: @unchecked Sendable {}

// MARK: - Conversions (future-major-version cleanup)

extension Conversion: @unchecked Sendable {}
extension ReversibleConversion: @unchecked Sendable {}

// MARK: - Result-builder accumulator (future-major-version cleanup)

extension DataBuilder.Component: @unchecked Sendable {}
