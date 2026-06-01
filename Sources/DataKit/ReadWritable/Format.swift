// Format.swift

import Foundation

/// Any value that can appear inside a `FormatBuilder` result-builder context.
///
/// You usually do not implement this protocol directly — built-in primitives such as
/// ``Property``, ``Convert``, ``Custom``, ``Using``, ``Scope``, and ``Environment`` already
/// conform. Conditional conformances to ``ReadableProperty`` and ``WritableProperty``
/// determine whether the value can be used in a read, write, or read-write context.
public protocol FormatProperty<Root>: Sendable {
    associatedtype Root
}

/// The umbrella protocol for the three concrete format types: ``ReadFormat``, ``WriteFormat``,
/// and ``ReadWriteFormat``. The `init(_:)` requirement lets the framework flatten an array
/// of formats into a single one — used by the result builder when combining statements.
public protocol FormatType<Root>: FormatProperty {
    init(_ multiple: [Self])
}
