// SkipChecksumVerification.swift

import Foundation

private enum SkipChecksumVerificationKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

extension EnvironmentValues {

    /// When `true`, ``ChecksumProperty`` reads the checksum bytes without comparing them
    /// against the computed checksum.
    ///
    /// Useful for parsing corrupted or partial captures where you want the value (typically
    /// exposed via the optional `keyPath` argument on ``ChecksumProperty``) but cannot
    /// require the bytes to match. The default is `false`.
    public var skipChecksumVerification: Bool {
        get { self[SkipChecksumVerificationKey.self] }
        set { self[SkipChecksumVerificationKey.self] = newValue }
    }
}

extension FormatProperty {

    /// Disables (or re-enables) checksum verification for the wrapped subtree.
    public func skipChecksumVerification(_ value: Bool = true) -> EnvironmentProperty<Self> {
        environment(\.skipChecksumVerification, value)
    }
}
