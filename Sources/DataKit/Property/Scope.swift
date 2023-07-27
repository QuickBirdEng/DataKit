//
//  File.swift
//  
//
//  Created by Paul Kraft on 14.07.23.
//

import Foundation

public struct Scope<Format: FormatProperty>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root

    // MARK: Stored Properties

    private let endInset: Int
    private let format: Format

    // MARK: Initialization

    public init<Root: Readable>(
        endInset: Int = 0,
        @FormatBuilder<Root, Format> format: () -> Format
    ) where Format == ReadFormat<Root> {
        self.endInset = endInset
        self.format = format()
    }

    public init<Root: Writable>(
        @FormatBuilder<Root, Format> format: () -> Format
    ) where Format == WriteFormat<Root> {
        self.endInset = 0
        self.format = format()
    }

    public init<Root: ReadWritable>(
        endInset: Int = 0,
        @FormatBuilder<Root, Format> format: () -> Format
    ) where Format == ReadWriteFormat<Root> {
        self.endInset = endInset
        self.format = format()
    }

}

extension Scope: ReadableProperty where Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        guard let endIndex = container.data.index(container.data.endIndex, offsetBy: -endInset, limitedBy: container.index) else {
            throw ReadContainer.LengthExceededError()
        }
        var nestedContainer = ReadContainer(data: container.data[container.index..<endIndex], environment: container.environment)
        try format.read(from: &nestedContainer, context: &context)
        let distance = nestedContainer.data.distance(from: nestedContainer.data.startIndex, to: nestedContainer.index)
        container.index = container.data.index(container.index, offsetBy: distance)
    }
}

extension Scope: WritableProperty where Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        var nestedContainer = WriteContainer(environment: container.environment)
        try format.write(to: &nestedContainer, using: root)
        container.append(nestedContainer.data)
    }
}
