// Sendable.swift
//
// `Sendable` conformances for DataKit's value-type formats, conversions, containers, and
// environment.
//
// Two design notes:
//
// 1. Several types here are marked `@unchecked Sendable` rather than `Sendable`. The reason
//    is almost always one of: (a) they store an `@escaping` closure whose generic
//    parameters Swift cannot statically prove sendable; (b) they store a `KeyPath`, which
//    only gained automatic `Sendable` inference in Swift 5.10 — DataKit's tools floor is
//    5.9. All such structs are immutable: their stored properties are `let`-bound and they
//    have no mutating methods, so concurrent use is sound in practice. If you add a
//    mutable stored property or a mutable method, revisit the conformance.
//
// 2. Closures supplied by users at the call site (e.g. inside `Custom`, `Convert`, `Using`)
//    are not marked `@Sendable` in the public initializers. That would be a source-breaking
//    API change. Capturing non-`Sendable` mutable state from such a closure and then
//    sending the resulting `FormatProperty` across actor boundaries is undefined behavior
//    today; document this as a known limitation rather than fix it via API breakage.

import Foundation

// MARK: - Containers

extension ReadContainer: @unchecked Sendable {}
extension WriteContainer: @unchecked Sendable {}
extension ReadContext: @unchecked Sendable {}

// MARK: - Environment

extension EnvironmentValues: @unchecked Sendable {}
// `Endianness: Sendable` and `Suffix: Sendable` are declared in their own source files
// because Swift 6 requires checked `Sendable` conformances to be co-located with the type.

// MARK: - Format types

extension ReadFormat: @unchecked Sendable {}
extension WriteFormat: @unchecked Sendable {}
extension ReadWriteFormat: @unchecked Sendable {}

// MARK: - Format-property primitives

extension Property: @unchecked Sendable {}
extension Scope: @unchecked Sendable {}
extension Using: @unchecked Sendable {}
extension Custom: @unchecked Sendable {}
extension Convert: @unchecked Sendable {}
extension Environment: @unchecked Sendable {}
extension EnvironmentProperty: @unchecked Sendable {}
extension OnRead: @unchecked Sendable {}
extension OnWrite: @unchecked Sendable {}
extension ChecksumProperty: @unchecked Sendable {}

// MARK: - Conversions

extension Conversion: @unchecked Sendable {}
extension ReversibleConversion: @unchecked Sendable {}

// MARK: - Sequence wrappers
//
// `PrefixCountArray` and `DynamicCountArray` declare their conditional `Sendable`
// conformance inline in their own source files (same-file rule for checked conformances).

// MARK: - Result-builder accumulator

extension DataBuilder.Component: @unchecked Sendable {}
