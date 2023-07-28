//
//  File.swift
//  
//
//  Created by Paul Kraft on 28.07.23.
//

import Foundation

extension KeyPath: FormatProperty {}

extension KeyPath: ReadableProperty where Root: Readable, Value: Readable {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try context.write(Value(from: &container), for: self)
    }
}

extension KeyPath: WritableProperty where Root: Writable, Value: Writable {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        try root[keyPath: self].write(to: &container)
    }
}
