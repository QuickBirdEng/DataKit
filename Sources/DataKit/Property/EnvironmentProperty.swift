//
//  File.swift
//  
//
//  Created by Paul Kraft on 25.06.23.
//

import Foundation

extension FormatProperty {

    public func environment<Value>(
        _ keyPath: WritableKeyPath<EnvironmentValues, Value>,
        _ value: Value
    ) -> EnvironmentProperty<Self> {
        EnvironmentProperty(self) { $0[keyPath: keyPath] = value }
    }

    public func transformEnvironment<Value>(
        _ keyPath: WritableKeyPath<EnvironmentValues, Value>,
        transform: @escaping (inout Value) throws -> Void
    ) -> EnvironmentProperty<Self> {
        EnvironmentProperty(self) { try transform(&$0[keyPath: keyPath]) }
    }

    public func transformEnvironment(
        transform: @escaping (inout EnvironmentValues) throws -> Void
    ) -> EnvironmentProperty<Self> {
        EnvironmentProperty(self) { try transform(&$0) }
    }

}

public struct EnvironmentProperty<Format: FormatProperty>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    private let format: Format
    private let transform: (inout EnvironmentValues) throws -> Void

    // MARK: Initialization

    public init(
        _ format: Format,
        transform: @escaping (inout EnvironmentValues) throws -> Void
    ) {
        self.format = format
        self.transform = transform
    }

}

extension EnvironmentProperty: ReadableProperty where Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        let previousEnvironment = container.environment
        try transform(&container.environment)
        try format.read(from: &container, context: &context)
        container.environment = previousEnvironment
    }
}

extension EnvironmentProperty: WritableProperty where Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        let previousEnvironment = container.environment
        try transform(&container.environment)
        try format.write(to: &container, using: root)
        container.environment = previousEnvironment
    }
}
