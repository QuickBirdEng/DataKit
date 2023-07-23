//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

private struct SuffixKey: EnvironmentKey {
    static var defaultValue: Data? { nil }
}

extension EnvironmentValues {
    public var suffix: Data? {
        get { self[SuffixKey.self] }
        set { self[SuffixKey.self] = newValue }
    }
}

extension FormatProperty {

    public func suffix(_ data: Data?) -> EnvironmentProperty<Self> {
        environment(\.suffix, data)
    }

    public func suffix<V: Writable>(_ value: V) -> EnvironmentProperty<Self> {
        transformEnvironment { environment in
            environment.suffix = try value.write(with: environment)
        }
    }

}
