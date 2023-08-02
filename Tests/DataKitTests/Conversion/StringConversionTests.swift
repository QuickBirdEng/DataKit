//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.07.23.
//

import DataKit
import XCTest

final class StringConversionTests: XCTestCase {

    func testVariableCountNoSuffix() {
        struct Wrapper: ReadWritable {
            let value: String

            init(value: String) {
                self.value = value
            }

            init(from context: ReadContext<Wrapper>) throws {
                self.value = try context.read(for: \.value)
            }

            static var format: Format {
                Scope(endInset: MemoryLayout<UInt32>.size) {
                    Convert(\.value) {
                        $0.encoded(.utf8).dynamicCount
                    }
                }

                CRC32.default
            }
        }

        for value in ["", "abc", "😂☺️", "1234"] {
            let wrapper = Wrapper(value: value)
            XCTAssertNoThrow {
                let data = try wrapper.write()
                let decodedWrapper = try Wrapper(data)
                XCTAssertEqual(decodedWrapper.value, value)
                XCTAssertEqual(try decodedWrapper.write(), data)
            }
        }
    }

    func testVariableCountSuffix() {
        struct Wrapper: ReadWritable {
            let value: String

            init(value: String) {
                self.value = value
            }

            init(from context: ReadContext<Wrapper>) throws {
                self.value = try context.read(for: \.value)
            }

            static var format: Format {
                Convert(\.value) {
                    $0.encoded(.utf8).dynamicCount
                }
                .suffix(0 as UInt8)

                CRC32.default
            }
        }

        for value in ["", "abc", "😂☺️", "1234"] {
            let wrapper = Wrapper(value: value)
            XCTAssertNoThrow {
                let data = try wrapper.write()
                let decodedWrapper = try Wrapper(data)
                XCTAssertEqual(decodedWrapper.value, value)
                XCTAssertEqual(try decodedWrapper.write(), data)
            }
        }
    }

    func testPrefixCount() {
        struct Wrapper: ReadWritable {
            let value: String

            init(value: String) {
                self.value = value
            }

            init(from context: ReadContext<Wrapper>) throws {
                self.value = try context.read(for: \.value)
            }

            static var format: Format {
                Convert(\.value) {
                    $0.encoded(.utf8).prefixCount(UInt8.self)
                }

                CRC32.default
            }
        }

        for value in ["", "abc", "😂☺️", "1234"] {
            let wrapper = Wrapper(value: value)
            XCTAssertNoThrow {
                let data = try wrapper.write()
                let decodedWrapper = try Wrapper(data)
                XCTAssertEqual(decodedWrapper.value, value)
                XCTAssertEqual(try decodedWrapper.write(), data)
            }
        }
    }

}
