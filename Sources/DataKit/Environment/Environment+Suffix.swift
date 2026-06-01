// Environment+Suffix.swift

import Foundation

/// A terminator marker for ``DynamicCountArray`` and similar variable-length sequences.
///
/// `isRequired == true` means the terminator must be encountered for reads to succeed; if
/// the underlying stream ends before the terminator is seen, the inner element read will
/// throw ``ReadContainer/LengthExceededError``. `isRequired == false` means the read may
/// also stop cleanly at end-of-buffer.
public struct Suffix: Sendable {

    /// The byte sequence that terminates the value (e.g. `Data([0x00])` for a C-string).
    public let data: Data

    /// Whether reading must encounter the terminator before EOF.
    public let isRequired: Bool

}

private struct SuffixKey: EnvironmentKey {
    static var defaultValue: Suffix? { nil }
}

extension EnvironmentValues {

    /// The active terminator for variable-length sequences inside the surrounding format.
    ///
    /// When `nil` (the default), variable-count reads consume until the end of the current
    /// container. When set, reads stop after consuming the terminator (or, if
    /// ``Suffix/isRequired`` is `false`, at EOF). On write, the terminator is appended
    /// after the elements.
    public var suffix: Suffix? {
        get { self[SuffixKey.self] }
        set { self[SuffixKey.self] = newValue }
    }
}

extension FormatProperty {

    /// Sets the terminator for the wrapped subtree using raw bytes.
    public func suffix(_ data: Data?, isRequired: Bool = true) -> EnvironmentProperty<Self> {
        environment(\.suffix, data.map { .init(data: $0, isRequired: isRequired) })
    }

    /// Sets the terminator for the wrapped subtree by serializing a ``Writable`` value with
    /// the current environment, then using its bytes as the terminator.
    public func suffix<V: Writable>(_ value: V, isRequired: Bool = true) -> EnvironmentProperty<Self> {
        transformEnvironment { environment in
            let data = try value.write(with: environment)
            environment.suffix = .init(data: data, isRequired: isRequired)
        }
    }

}
