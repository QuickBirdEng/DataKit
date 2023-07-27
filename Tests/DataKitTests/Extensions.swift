//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.07.23.
//

import XCTest

extension Data {

    func copy(transform: (inout Data) -> Void) -> Data {
        var copy = self
        transform(&copy)
        return copy
    }

    var byteArrayDescription: String {
        "[" + map { String(format: "0x%02hX", $0) }.joined(separator: ", ") + "]"
    }

}

func XCTAssertNoThrow(_ run: () throws -> Void) {
    XCTAssertNoThrow(try run())
}
