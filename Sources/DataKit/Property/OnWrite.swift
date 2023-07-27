//
//  File.swift
//  
//
//  Created by Paul Kraft on 14.07.23.
//

import Foundation

public struct OnWrite<Root: ReadWritable>: ReadableProperty, WritableProperty {

    // MARK: Stored Properties

    private let format: WriteFormat<Root>

    // MARK: Initialization

    public init(@WriteFormatBuilder<Root> format: () -> WriteFormat<Root>) {
        self.format = format()
    }

    // MARK: Methods

    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {}

    public func write(to container: inout WriteContainer, using root: Root) throws {
        try format.write(to: &container, using: root)
    }

}
