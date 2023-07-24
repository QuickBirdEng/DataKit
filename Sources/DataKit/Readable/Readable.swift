//
//  File.swift
//  
//
//  Created by Paul Kraft on 21.06.23.
//

import Foundation

public protocol Readable {

    init(from context: ReadContext<Self>) throws

    @ReadBuilder
    static var readFormat: ReadFormat<Self> { get throws }

}

extension Readable {

    public typealias ReadBuilder = ReadFormatBuilder<Self>

    public init(from container: inout ReadContainer) throws {
        var context = ReadContext<Self>()
        try Self.readFormat.read(from: &container, context: &context)
        try self.init(from: context)
    }

    public init(_ data: Data, environment: EnvironmentValues = EnvironmentValues()) throws {
        var container = ReadContainer(data: data, environment: environment)
        try self.init(from: &container)
    }

    public init(_ data: Data, transform: (inout EnvironmentValues) throws -> Void) throws {
        var environment = EnvironmentValues()
        try transform(&environment)
        try self.init(data, environment: environment)
    }

}
