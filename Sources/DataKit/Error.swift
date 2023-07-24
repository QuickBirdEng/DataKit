//
//  File.swift
//  
//
//  Created by Paul Kraft on 15.07.23.
//

import Foundation

public struct ConversionError: Error {
    public let source: Any
    public let targetType: Any.Type
}

public struct CannotWriteNilError: Error {}

public struct UnexpectedValueError: Error {
    public let expectedValue: Any
    public let actualValue: Any
}
