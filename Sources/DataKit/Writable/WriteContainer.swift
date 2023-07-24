//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.06.23.
//

import Foundation

public struct WriteContainer {

    // MARK: Stored Properties

    public private(set) var data: Data
    public var environment: EnvironmentValues

    // MARK: Initialization

    public init(
        data: Data = Data(),
        environment: EnvironmentValues
    ) {
        self.data = data
        self.environment = environment
    }

    // MARK: Methods

    public mutating func transform<V>(_ transform: (inout Data) throws -> V) rethrows -> V {
        try transform(&data)
    }

    public mutating func append(_ newData: Data) {
        data.append(newData)
    }

    public mutating func append<SourceType>(_ buffer: UnsafeBufferPointer<SourceType>) {
        data.append(buffer)
    }

    public mutating func append(contentsOf bytes: [UInt8]) {
        data.append(contentsOf: bytes)
    }

    public mutating func append<S: Sequence<UInt8>>(contentsOf elements: S) {
        data.append(contentsOf: elements)
    }

}
