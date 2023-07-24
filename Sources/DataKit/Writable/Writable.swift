//
//  File.swift
//  
//
//  Created by Paul Kraft on 21.06.23.
//

import Foundation

public protocol Writable {

    @WriteBuilder
    static var writeFormat: WriteFormat<Self> { get throws }

}

extension Writable {

    public typealias WriteBuilder = WriteFormatBuilder<Self>

    public func write(to container: inout WriteContainer) throws {
        try Self.writeFormat.write(to: &container, using: self)
    }

    public func write(with environment: EnvironmentValues = EnvironmentValues()) throws -> Data {
        var container = WriteContainer(environment: environment)
        try write(to: &container)
        return container.data
    }

    public func write(transform: (inout EnvironmentValues) throws -> Void) throws -> Data {
        var environment = EnvironmentValues()
        try transform(&environment)
        return try write(with: environment)
    }

}
