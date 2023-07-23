//
//  File.swift
//  
//
//  Created by Paul Kraft on 21.06.23.
//

import Foundation

public protocol WritableProperty<Root>: FormatProperty where Root: Writable {
    func write(to container: inout WriteContainer, using root: Root) throws
}

public struct WriteFormat<Root: Writable>: WritableProperty {

    // MARK: Stored Properties

    private let _write: (inout WriteContainer, Root) throws -> Void

    // MARK: Initialization

    public init(write: @escaping (inout WriteContainer, Root) throws -> Void) {
        self._write = write
    }

    // MARK: Methods

    public func write(to container: inout WriteContainer, using root: Root) throws {
        try _write(&container, root)
    }

}

extension WriteFormat: FormatType {

    public init(_ multiple: [WriteFormat<Root>]) {
        self.init { container, root in
            for format in multiple {
                try format.write(to: &container, using: root)
            }
        }
    }

}
