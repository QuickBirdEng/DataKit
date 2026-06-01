// KeyPath.swift
//
// `KeyPath` is logically Sendable — every key path is an immutable value-semantics-like
// reference to a property path. The Swift stdlib does not (yet) conform `KeyPath` to
// `Sendable` in the toolchain we target (5.10), so we add a retroactive `@unchecked`
// conformance here.
//
// The `@retroactive` annotation (which makes the retroactive conformance explicit and
// silences the "extension declares a conformance of imported type" warning) is only
// recognized by the Swift 6+ compiler. The 5.10 compiler rejects it as an unknown
// attribute, so we gate it on the compiler version and fall back to the bare conformance.
//
// Once the stdlib adds the conformance natively, this file can be removed.
#if compiler(>=6.0)
extension AnyKeyPath: @retroactive @unchecked Sendable {}
#else
extension AnyKeyPath: @unchecked Sendable {}
#endif

// Bare key-path expressions (e.g. `\.magic`) inside a format builder are handled by the
// dedicated `buildExpression<Value: Readable>(_ expression: KeyPath<Root, Value>)` and
// matching write/read-write overloads in `Builder/FormatBuilder+Read.swift` etc. They
// lift the key path into a `Property(_:)` automatically.
//
// We do not conform `KeyPath` itself to `FormatProperty` / `ReadableProperty` /
// `WritableProperty` because those would be retroactive conformances by protocols that
// now require `Sendable`, which trips Swift 6's "conformance must occur in the same
// source file" rule. If you need to pass a key path where a `FormatProperty` is expected
// outside a builder context, wrap it explicitly with `Property(\.field)`.
