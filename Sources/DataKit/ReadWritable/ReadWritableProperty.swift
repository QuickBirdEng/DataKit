//
//  File.swift
//  
//
//  Created by Paul Kraft on 22.06.23.
//

import Foundation

public struct ReadWriteFormat<Root: ReadWritable>: FormatType, ReadableProperty, WritableProperty {

    // MARK: Stored Properties

    private let readFormat: ReadFormat<Root>
    private let writeFormat: WriteFormat<Root>

    // MARK: Initialization

    public init(read: ReadFormat<Root>, write: WriteFormat<Root>) {
        self.readFormat = read
        self.writeFormat = write
    }

    public init(_ multiple: [ReadWriteFormat<Root>]) {
        self.init(
            read: .init(multiple.map(\.readFormat)),
            write: .init(multiple.map(\.writeFormat))
        )
    }

    // MARK: Methods

    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try readFormat.read(from: &container, context: &context)
    }

    public func write(to container: inout WriteContainer, using root: Root) throws {
        try writeFormat.write(to: &container, using: root)
    }

}
