// Checksum.swift

import Foundation

/// A format property that reads/writes a checksum value covering the bytes accumulated so far
/// in the current container.
///
/// On decode, `ChecksumProperty` reads `ChecksumType.Value` bytes from the input, computes the
/// expected value over ``ReadContainer/consumedData``, and throws on mismatch — unless
/// ``EnvironmentValues/skipChecksumVerification`` is `true`, in which case the value is read
/// without comparison. The checksum bytes are always read and written in big-endian byte order,
/// regardless of the surrounding environment endianness.
///
/// On encode, the value is computed over the buffer accumulated so far and appended, unless
/// the optional `keyPath` argument carries a non-nil value, in which case that value is used
/// verbatim.
///
/// To control which bytes the checksum covers, wrap the relevant section in a ``Scope``:
///
/// ```swift
/// Scope(endInset: 4) {           // reserve 4 trailing bytes for the CRC
///     \.payload
/// }
/// CRC32.default                  // bare checksum expression covers the scope
/// ```
public struct ChecksumProperty<ChecksumType: Checksum & Sendable, Format: FormatType>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root
    public typealias Value = ChecksumType.Value

    // MARK: Stored Properties

    internal let format: Format

    // MARK: Initialization

    /// Reads and verifies a checksum, optionally exposing the decoded value at `keyPath`.
    ///
    /// - Parameters:
    ///   - checksum: The checksum algorithm.
    ///   - keyPath: Optional path that, when provided, stores the decoded checksum value into
    ///     the `ReadContext`. When `nil`, the value is verified and discarded.
    public init<Root: Readable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, ChecksumType.Value>? = nil
    ) where Format == ReadFormat<Root>, ChecksumType.Value: Readable & Sendable {
        self.format = ReadFormatBuilder.buildExpression(
            ReadFormat { container, context in
                let verificationData = container.consumedData
                let value = try ChecksumType.Value(from: &container)
                if !container.environment.skipChecksumVerification {
                    try checksum.verify(value, for: verificationData)
                }
                if let keyPath {
                    try context.write(value, for: keyPath)
                }
            }
            .endianness(.big)
        )
    }

    /// Reads and verifies a checksum, optionally exposing the decoded value at an
    /// optional-typed `keyPath`.
    public init<Root: Readable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, ChecksumType.Value?>? = nil
    ) where Format == ReadFormat<Root>, ChecksumType.Value: Readable & Sendable {
        self.format = ReadFormatBuilder.buildExpression(
            ReadFormat { container, context in
                let verificationData = container.consumedData
                let value = try ChecksumType.Value(from: &container)
                if !container.environment.skipChecksumVerification {
                    try checksum.verify(value, for: verificationData)
                }
                if let keyPath {
                    try context.write(value, for: keyPath)
                }
            }
            .endianness(.big)
        )
    }

    /// Writes a checksum computed over the buffer so far, or — if `keyPath` is non-nil —
    /// writes the value carried by `Root` directly.
    public init<Root: Writable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, ChecksumType.Value>? = nil
    ) where Format == WriteFormat<Root>, ChecksumType.Value: Writable & Sendable {
        self.format = WriteFormatBuilder.buildExpression(
            WriteFormat { container, root in
                let value = keyPath.map { root[keyPath: $0] }
                    ?? checksum.calculate(for: container.data)
                try value.write(to: &container)
            }
            .endianness(.big)
        )
    }

    /// Writes a checksum, sourcing the value from an optional-typed property on `Root`.
    /// If the property is `nil`, the checksum is computed over the buffer instead.
    public init<Root: Writable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, ChecksumType.Value?>? = nil
    ) where Format == WriteFormat<Root>, ChecksumType.Value: Writable & Sendable {
        self.format = WriteFormatBuilder.buildExpression(
            WriteFormat { container, root in
                let value = keyPath.flatMap { root[keyPath: $0] }
                    ?? checksum.calculate(for: container.data)
                try value.write(to: &container)
            }
            .endianness(.big)
        )
    }

    /// Unified read/write of a checksum for a ``ReadWritable`` root.
    public init<Root: ReadWritable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, ChecksumType.Value>? = nil
    ) where Format == ReadWriteFormat<Root>, ChecksumType.Value: ReadWritable & Sendable {
        self.format = ReadWriteFormatBuilder.buildExpression(
            ReadWriteFormat(
                read: .init { container, context in
                    let verificationData = container.consumedData
                    let value = try ChecksumType.Value(from: &container)
                    if !container.environment.skipChecksumVerification {
                        try checksum.verify(value, for: verificationData)
                    }
                    if let keyPath {
                        try context.write(value, for: keyPath)
                    }
                },
                write: .init { container, root in
                    let value = keyPath.map { root[keyPath: $0] }
                    ?? checksum.calculate(for: container.data)
                    try value.write(to: &container)
                }
            )
            .endianness(.big)
        )
    }

    /// Unified read/write of a checksum for a ``ReadWritable`` root with an optional value path.
    public init<Root: ReadWritable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, ChecksumType.Value?>? = nil
    ) where Format == ReadWriteFormat<Root>, ChecksumType.Value: ReadWritable & Sendable {
        self.format = ReadWriteFormatBuilder.buildExpression(
            ReadWriteFormat(
                read: .init { container, context in
                    let verificationData = container.consumedData
                    let value = try ChecksumType.Value(from: &container)
                    if !container.environment.skipChecksumVerification {
                        try checksum.verify(value, for: verificationData)
                    }
                    if let keyPath {
                        try context.write(value, for: keyPath)
                    }
                },
                write: .init { container, root in
                    let value = keyPath.flatMap { root[keyPath: $0] }
                        ?? checksum.calculate(for: container.data)
                    try value.write(to: &container)
                }
            )
            .endianness(.big)
        )
    }

}

extension ChecksumProperty: Sendable where Format: Sendable {}
