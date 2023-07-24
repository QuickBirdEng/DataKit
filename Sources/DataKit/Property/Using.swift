//
//  File.swift
//  
//
//  Created by Paul Kraft on 23.06.23.
//

import Foundation

public struct Using<Root, Value, Format: FormatType>: FormatProperty where Root == Format.Root {

    // MARK: Stored Properties

    let keyPath: KeyPath<Root, Value>
    let format: (Value) throws -> Format

}

extension Using where Format == ReadFormat<Root> {

    public init(
        _ keyPath: KeyPath<Root, Value>,
        @FormatBuilder<Format.Root, Format> with format: @escaping (Value) throws -> Format
    ) {
        self.keyPath = keyPath
        self.format = format
    }

}

extension Using where Format == WriteFormat<Root> {

    public init(
        _ keyPath: KeyPath<Root, Value>,
        @FormatBuilder<Format.Root, Format> with format: @escaping (Value) throws -> Format
    ) {
        self.keyPath = keyPath
        self.format = format
    }

}

extension Using where Format == ReadWriteFormat<Root> {

    public init(
        _ keyPath: KeyPath<Root, Value>,
        @FormatBuilder<Format.Root, Format> with format: @escaping (Value) throws -> Format
    ) {
        self.keyPath = keyPath
        self.format = format
    }

}

extension Using: ReadableProperty where Root: Readable, Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        let value = try context.read(for: keyPath)
        try format(value).read(from: &container, context: &context)
    }
}

extension Using: WritableProperty where Root: Writable, Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        let value = root[keyPath: keyPath]
        try format(value).write(to: &container, using: root)
    }
}

extension Using: ReadWritableProperty where Root: ReadWritable, Format: ReadWritableProperty {}
