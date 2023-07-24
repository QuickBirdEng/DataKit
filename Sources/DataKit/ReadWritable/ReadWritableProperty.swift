//
//  File.swift
//  
//
//  Created by Paul Kraft on 22.06.23.
//

import Foundation

public protocol ReadWritableProperty<Root>: ReadableProperty, WritableProperty where Root: ReadWritable {}

public struct ReadWriteFormat<Root: ReadWritable>: ReadWritableProperty {

    // MARK: Stored Properties

    private let _read: (inout ReadContainer, inout ReadContext<Root>) throws -> Void
    private let _write: (inout WriteContainer, Root) throws -> Void

    // MARK: Initialization

    public init(
        read: @escaping (inout ReadContainer, inout ReadContext<Root>) throws -> Void,
        write: @escaping (inout WriteContainer, Root) throws -> Void
    ) {
        self._read = read
        self._write = write
    }

    // MARK: Methods
    
    public func write(to container: inout WriteContainer, using root: Root) throws {
        try _write(&container, root)
    }

    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try _read(&container, &context)
    }

}

extension ReadWriteFormat: FormatType {

    public init(_ multiple: [ReadWriteFormat<Root>]) {
        self.init { container, context in
            for format in multiple {
                try format.read(from: &container, context: &context)
            }
        } write: { container, root in
            for format in multiple {
                try format.write(to: &container, using: root)
            }
        }
    }

}
