// ReadWritable+FloatingPoint.swift

import Foundation

/// A floating-point type whose bit pattern is a `FixedWidthInteger`, allowing it to be
/// serialized by reusing the integer encoding (and thus the current
/// ``EnvironmentValues/endianness``).
///
/// You will not normally conform your own types to this protocol — the standard library
/// floating-point types (`Float16` on arm64-only platforms, `Float32`, `Float64`) already
/// conform.
public protocol FixedWidthFloatingPoint: BinaryFloatingPoint {
    associatedtype BitPattern: FixedWidthInteger

    init(bitPattern: BitPattern)
    var bitPattern: BitPattern { get }
}

#if arch(arm64)
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension Float16: FixedWidthFloatingPoint, ReadWritable {}
#endif

extension Float32: FixedWidthFloatingPoint, ReadWritable {}
extension Float64: FixedWidthFloatingPoint, ReadWritable {}

extension FixedWidthFloatingPoint where Self: ReadWritable, BitPattern: ReadWritable {

    public init(from context: ReadContext<Self>) throws {
        try self.init(bitPattern: context.read(for: \.bitPattern))
    }

    @FormatBuilder
    public static var format: Format {
        \.bitPattern
    }

}
