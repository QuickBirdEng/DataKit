//
//  File.swift
//
//
//  Created by Paul Kraft on 26.07.23.
//

import Foundation

extension Property where Root: Readable {

    public func custom(
        read: @escaping (inout ReadContainer) -> Value
    ) -> ReadFormat<Root> {
        .init { container, context in
            try context.write(read(&container), for: keyPath)
        }
    }

}

extension Property where Root: Writable {

    public func custom(
        write: @escaping (inout WriteContainer, Value) throws -> Void
    ) -> WriteFormat<Root> {
        .init { container, root in
            try write(&container, root[keyPath: keyPath])
        }
    }

}

extension Property where Root: ReadWritable {

    public func custom(
        read: @escaping (inout ReadContainer) -> Value,
        write: @escaping (inout WriteContainer, Value) throws -> Void
    ) -> ReadWriteFormat<Root> {
        ReadWriteFormat(
            read: custom(read: read),
            write: custom(write: write)
        )
    }

}
