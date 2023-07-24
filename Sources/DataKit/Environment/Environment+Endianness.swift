//
//  File.swift
//  
//
//  Created by Paul Kraft on 24.06.23.
//

import Foundation

public enum Endianness: Equatable {
    case little
    case big
}

private enum EndiannessKey: EnvironmentKey {
    static var defaultValue: Endianness? { nil }
}

extension EnvironmentValues {
    public var endianness: Endianness? {
        get { self[EndiannessKey.self] }
        set { self[EndiannessKey.self] = newValue }
    }
}

extension FormatProperty {
    public func endianness(_ value: Endianness?) -> EnvironmentProperty<Self> {
        environment(\.endianness, value)
    }
}
