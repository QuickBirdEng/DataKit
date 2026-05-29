// Error.swift

import Foundation

/// Thrown by a `Conversion` or `ReversibleConversion` when the input value cannot be represented in the target type.
///
/// The stored values are intended for debugging — they are type-erased to `Any` so the error
/// type itself can sit at the boundary between many different `Source`/`Target` pairs without
/// being made generic. To inspect them programmatically, cast `source` to the expected
/// source type and compare `targetType` against the expected target metatype.
///
/// The `Sendable` conformance is `@unchecked` because `source` is type-erased from conversion
/// operators whose `Source` is not constrained to `Sendable`. This is sound: the struct is
/// immutable and exposes no way to mutate the boxed value, so there is nothing to race on.
public struct ConversionError: Error, @unchecked Sendable {

    /// The value that could not be converted.
    public let source: Any

    /// The target type the conversion was attempting to produce.
    public let targetType: Any.Type
}

/// Thrown by a `ReadBuilder` when an expected literal value does not match the actual bytes read.
///
/// Bare literal expressions inside a `ReadBuilder` (for example, `UInt8(0x02)` as a frame
/// prefix) parse the corresponding bytes and assert equality with the literal. A mismatch
/// throws this error. Both stored values are `Readable & Equatable` literals, which are
/// `Sendable`, so the values are type-erased to `any Sendable` rather than `Any`.
public struct UnexpectedValueError: Error, Sendable {

    /// The value declared in the format declaration.
    public let expectedValue: any Sendable

    /// The value actually decoded from the input data.
    public let actualValue: any Sendable
}
