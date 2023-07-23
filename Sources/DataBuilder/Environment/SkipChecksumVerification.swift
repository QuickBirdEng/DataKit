//
//  File.swift
//  
//
//  Created by Paul Kraft on 15.07.23.
//

import Foundation

private enum SkipChecksumVerificationKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

extension EnvironmentValues {
    public var skipChecksumVerification: Bool {
        get { self[SkipChecksumVerificationKey.self] }
        set { self[SkipChecksumVerificationKey.self] = newValue }
    }
}

extension FormatProperty {
    public func skipChecksumVerification(_ value: Bool = true) -> EnvironmentProperty<Self> {
        environment(\.skipChecksumVerification, value)
    }
}
