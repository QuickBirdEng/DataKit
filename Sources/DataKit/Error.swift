// Error.swift

import Foundation

/// Thrown by a `Conversion` or `ReversibleConversion` when the input value cannot be represented in the target type.
///
/// The stored values are intended for debugging — they are type-erased to `Any` so the error
/// type itself can sit at the boundary between many different `Source`/`Target` pairs without
/// being made generic. To inspect them programmatically, cast `source` to the expected
/// source type and compare `targetType` against the expected target metatype.
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
/// throws this error.
public struct UnexpectedValueError: Error, @unchecked Sendable {

    /// The value declared in the format declaration.
    public let expectedValue: Any

    /// The value actually decoded from the input data.
    public let actualValue: Any
}
