//
//  File.swift
//  
//
//  Created by Paul Kraft on 21.06.23.
//

import Foundation

public protocol ReadableProperty<Root>: FormatProperty where Root: Readable {
    func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws
}

public struct ReadFormat<Root: Readable>: ReadableProperty {

    // MARK: Stored Properties

    private let _read: (inout ReadContainer, inout ReadContext<Root>) throws -> Void

    // MARK: Initialization

    public init(read: @escaping (inout ReadContainer, inout ReadContext<Root>) throws -> Void) {
        self._read = read
    }

    // MARK: Methods

    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try _read(&container, &context)
    }

}

extension ReadFormat: FormatType {
    public init(_ multiple: [ReadFormat<Root>]) {
        self.init { container, context in
            for format in multiple {
                try format.read(from: &container, context: &context)
            }
        }
    }
}
