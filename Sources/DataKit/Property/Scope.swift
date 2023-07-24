//
//  File.swift
//  
//
//  Created by Paul Kraft on 14.07.23.
//

import Foundation

public struct Scope<Root, Format: FormatProperty>: FormatProperty where Root == Format.Root {

    // MARK: Stored Properties

    private let format: Format
    private let endInset: Int

}

extension Scope where Root: Readable, Format == ReadFormat<Root> {
    public init(endInset: Int = 0, @FormatBuilder<Format.Root, Format> format: () -> Format) {
        self.format = format()
        self.endInset = endInset
    }
}

extension Scope where Root: Writable, Format == WriteFormat<Root> {
    public init(@FormatBuilder<Format.Root, Format> format: () -> Format) {
        self.format = format()
        self.endInset = 0
    }
}

extension Scope where Root: ReadWritable, Format == ReadWriteFormat<Root> {
    public init(endInset: Int = 0, @FormatBuilder<Format.Root, Format> format: () -> Format) {
        self.format = format()
        self.endInset = endInset
    }
}

extension Scope: ReadableProperty where Root: Readable, Format: ReadableProperty {
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

extension Scope: WritableProperty where Root: Writable, Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        var nestedContainer = WriteContainer(environment: container.environment)
        try format.write(to: &nestedContainer, using: root)
        container.append(nestedContainer.data)
    }
}

extension Scope: ReadWritableProperty where Root: ReadWritable, Format: ReadWritableProperty {}
