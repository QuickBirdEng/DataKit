//
//  File.swift
//
//
//  Created by Paul Kraft on 26.07.23.
//

import Foundation

extension Property where Root: Readable {

    public func read(
        _ read: @escaping (inout ReadContainer) -> Value
    ) -> Custom<ReadFormat<Root>> {
        Custom(keyPath, read: read)
    }

}

extension Property where Root: Writable {

    public func write(
        _ write: @escaping (inout WriteContainer, Value) throws -> Void
    ) -> Custom<WriteFormat<Root>> {
        Custom(keyPath, write: write)
    }

}

extension Property where Root: ReadWritable {

    public func read(
        _ read: @escaping (inout ReadContainer) -> Value,
        write: @escaping (inout WriteContainer, Value) throws -> Void
    ) -> Custom<ReadWriteFormat<Root>> {
        Custom(keyPath, read: read, write: write)
    }

}
