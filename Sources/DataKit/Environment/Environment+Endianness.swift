// Environment+Endianness.swift

import Foundation

/// The byte order used when (de)serializing fixed-width numeric types.
public enum Endianness: Equatable, Sendable {

    /// Least-significant byte first.
    case little

    /// Most-significant byte first.
    case big
}

private enum EndiannessKey: EnvironmentKey {
    static var defaultValue: Endianness? { nil }
}

extension EnvironmentValues {

    /// The byte order used for integer and floating-point fields.
    ///
    /// Defaults to `nil`, which means **host-native** byte order. Most wire protocols call
    /// for a specific byte order — set this explicitly (typically `.big` or `.little`) at
    /// the top of your format, or via the ``DataKit/FormatProperty/endianness(_:)`` modifier,
    /// to avoid surprises when running on hardware with different native order.
    ///
    /// Checksum bytes are always written in big-endian and are unaffected by this setting.
    public var endianness: Endianness? {
        get { self[EndiannessKey.self] }
        set { self[EndiannessKey.self] = newValue }
    }
}

extension FormatProperty {

    /// Sets the endianness for the wrapped format subtree.
    ///
    /// - Parameter value: The byte order, or `nil` to reset to host-native within the subtree.
    public func endianness(_ value: Endianness?) -> EnvironmentProperty<Self> {
        environment(\.endianness, value)
    }
}
