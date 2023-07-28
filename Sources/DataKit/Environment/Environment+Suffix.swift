//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

public struct Suffix {
    public let data: Data
    public let isRequired: Bool

}

private struct SuffixKey: EnvironmentKey {
    static var defaultValue: Suffix? { nil }
}

extension EnvironmentValues {
    public var suffix: Suffix? {
        get { self[SuffixKey.self] }
        set { self[SuffixKey.self] = newValue }
    }
}

extension FormatProperty {

    public func suffix(_ data: Data?, isRequired: Bool = true) -> EnvironmentProperty<Self> {
        environment(\.suffix, data.map { .init(data: $0, isRequired: isRequired) })
    }

    public func suffix<V: Writable>(_ value: V, isRequired: Bool = true) -> EnvironmentProperty<Self> {
        transformEnvironment { environment in
            let data = try value.write(with: environment)
            environment.suffix = .init(data: data, isRequired: isRequired)
        }
    }

}
