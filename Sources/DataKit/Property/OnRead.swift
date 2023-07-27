//
//  File.swift
//  
//
//  Created by Paul Kraft on 14.07.23.
//

import Foundation

public struct OnRead<Root: ReadWritable>: ReadableProperty, WritableProperty {

    // MARK: Stored Properties

    private let format: ReadFormat<Root>

    // MARK: Initialization

    public init(@ReadFormatBuilder<Root> format: () -> ReadFormat<Root>) {
        self.format = format()
    }

    // MARK: Methods

    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try format.read(from: &container, context: &context)
    }

    public func write(to container: inout WriteContainer, using root: Root) throws {}

}
