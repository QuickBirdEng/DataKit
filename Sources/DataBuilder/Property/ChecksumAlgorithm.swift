//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.06.23.
//

import Foundation

public struct ChecksumError<Value: FixedWidthInteger>: Error {

    public let actualValue: Value
    public let expectedValue: Value

}

public protocol ChecksumAlgorithm {

    associatedtype Value: FixedWidthInteger

    func calculate(for data: Data) -> Value

}

extension ChecksumAlgorithm {

    public func verify(_ expectedValue: Value, for data: Data) throws {
        let actualValue = calculate(for: data)
        guard actualValue == expectedValue else {
            throw ChecksumError(actualValue: actualValue, expectedValue: expectedValue)
        }
    }

}

extension ChecksumAlgorithm where Self == XORChecksum {

    public static var xor: XORChecksum {
        return XORChecksum()
    }

}

public struct XORChecksum: ChecksumAlgorithm {

    public init() {}

    public func calculate(for data: Data) -> UInt8 {
        data.reduce(0, ^)
    }

}
