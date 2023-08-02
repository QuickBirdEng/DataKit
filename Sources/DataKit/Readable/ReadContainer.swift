//
//  File.swift
//  
//
//  Created by Paul Kraft on 15.07.23.
//

import Foundation

public struct ReadContainer {

    // MARK: Nested Types

    public struct LengthExceededError: Error {}

    // MARK: Stored Properties

    public let data: Data
    public var index: Data.Index
    public var environment: EnvironmentValues

    // MARK: Computed Properties

    public var consumedData: Data {
        data.prefix(upTo: index)
    }

    public var remainingData: Data {
        data.suffix(from: index)
    }

    // MARK: Initialization

    public init(
        data: Data,
        index: Data.Index? = nil,
        environment: EnvironmentValues
    ) {
        self.data = data
        self.index = index ?? data.startIndex
        self.environment = environment
    }

    // MARK: Methods

    public mutating func consume(_ count: Int) throws -> Data {
        guard count <= data.distance(from: index, to: data.endIndex) else {
            throw LengthExceededError()
        }
        let newIndex = data.index(index, offsetBy: count)
        defer { index = newIndex }
        return data[index..<newIndex]
    }

}
