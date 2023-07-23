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

public struct EnvironmentProperty<Content: FormatProperty> {

    // MARK: Stored Properties

    private let content: Content
    private let transform: (inout EnvironmentValues) throws -> Void

    // MARK: Initialization

    public init(
        _ content: Content,
        transform: @escaping (inout EnvironmentValues) throws -> Void
    ) {
        self.content = content
        self.transform = transform
    }

}

extension EnvironmentProperty: FormatProperty where Content: FormatProperty {
    public typealias Root = Content.Root
}

extension EnvironmentProperty: ReadableProperty where Content: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        let previousEnvironment = container.environment
        try transform(&container.environment)
        try content.read(from: &container, context: &context)
        container.environment = previousEnvironment
    }
}

extension EnvironmentProperty: WritableProperty where Content: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        let previousEnvironment = container.environment
        try transform(&container.environment)
        try content.write(to: &container, using: root)
        container.environment = previousEnvironment
    }
}

extension EnvironmentProperty: ReadWritableProperty where Content: ReadWritableProperty {}
