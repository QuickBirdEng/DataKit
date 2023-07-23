//
//  File.swift
//  
//
//  Created by Paul Kraft on 15.07.23.
//

import Foundation

public struct Environment<Value, Root, Format: FormatType>: FormatProperty where Root == Format.Root {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    let keyPath: KeyPath<EnvironmentValues, Value>
    let format: (Value) throws -> Format

}

extension Environment where Format == ReadFormat<Root> {
    public init(
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        @FormatBuilder<Format.Root, Format> format: @escaping (Value) throws -> Format
    ) {
        self.keyPath = keyPath
        self.format = format
    }
}

extension Environment where Format == WriteFormat<Root> {
    public init(
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        @FormatBuilder<Format.Root, Format> format: @escaping (Value) throws -> Format
    ) {
        self.keyPath = keyPath
        self.format = format
    }
}

extension Environment where Format == ReadWriteFormat<Root> {
    public init(
        _ keyPath: KeyPath<EnvironmentValues, Value>,
        @FormatBuilder<Format.Root, Format> format: @escaping (Value) throws -> Format
    ) {
        self.keyPath = keyPath
        self.format = format
    }
}

extension Environment: ReadableProperty where Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        let value = container.environment[keyPath: keyPath]
        try format(value).read(from: &container, context: &context)
    }
}

extension Environment: WritableProperty where Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        let value = container.environment[keyPath: keyPath]
        try format(value).write(to: &container, using: root)
    }
}

extension Environment: ReadWritableProperty where Format: ReadWritableProperty {}
