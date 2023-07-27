//
//  File.swift
//  
//
//  Created by Paul Kraft on 14.07.23.
//

import Foundation

public struct Property<Root, Value>: FormatProperty {

    // MARK: Stored Properties

    internal let keyPath: KeyPath<Root, Value>

    // MARK: Initialization

    public init(_ keyPath: KeyPath<Root, Value>) {
        self.keyPath = keyPath
    }

}

extension Property: ReadableProperty where Root: Readable, Value: Readable {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        let value = try Value(from: &container)
        try context.write(value, for: keyPath)
    }
}

extension Property: WritableProperty where Root: Writable, Value: Writable {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        try root[keyPath: keyPath].write(to: &container)
    }
}
