//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.07.23.
//

import DataKit
import Foundation
import XCTest

final class ReadmeTests: XCTestCase {

    // MARK: Stored Properties

    private let allFeaturesValues = (0...0b111).map(WeatherStationFeatures.init(rawValue:))

    // MARK: Methods

    func testReadWriting() throws {
        let expectedCodings: [(WeatherStationUpdate, Data)] = [
            (.init(), Data([0x02, 0x00, 0x73, 0xEF, 0x70, 0x7D])),
            (.init(unit: .celsius), Data([0x02, 0x04, 0x74, 0x82, 0xB4, 0x64])),
            (.init(temperature: 32), Data([0x02, 0x01, 0x42, 0x00, 0x00, 0x00, 0xF0, 0x77, 0xB9, 0xAE])),
            (.init(humidity: 0.5), Data([0x02, 0x02, 0x32, 0x06, 0x24, 0x3E, 0x7E])),
            (.init(temperature: 0, unit: .celsius), Data([0x02, 0x05, 0x00, 0x00, 0x00, 0x00, 0x34, 0xEA, 0x8F, 0xD8])),
            (.init(temperature: 32, humidity: 0.5), Data([0x02, 0x03, 0x42, 0x00, 0x00, 0x00, 0x32, 0x66, 0x83, 0xE6, 0x50])),
            (.init(temperature: 0, unit: .celsius, humidity: 0.5), Data([0x02, 0x07, 0x00, 0x00, 0x00, 0x00, 0x32, 0xDF, 0x21, 0xAF, 0x6F])),
        ]

        for (expectedValue, expectedData) in expectedCodings {
            let writtenValue = try expectedValue.write()
            XCTAssertEqual(writtenValue, expectedData, "\(writtenValue.byteArrayDescription) != \(expectedData.byteArrayDescription)")
            let actualData = expectedValue.data
            XCTAssertEqual(actualData, expectedData, "\(actualData.byteArrayDescription) != \(expectedData.byteArrayDescription)")

            XCTAssertNoThrow {
                let readValue = try WeatherStationUpdate(expectedData)
                XCTAssertEqual(readValue, expectedValue)
            }

            let wrongPrefixData = expectedData.copy { $0[0] = 0x03 }
            XCTAssertNotEqual(wrongPrefixData, expectedData)
            XCTAssertThrowsError(try WeatherStationUpdate(wrongPrefixData)) { error in
                XCTAssert(error is UnexpectedValueError)
            }

            let wrongChecksumData = expectedData.copy { $0[$0.endIndex - 2] &+= 1 }
            XCTAssertNotEqual(wrongChecksumData, expectedData)
            XCTAssertThrowsError(try WeatherStationUpdate(wrongChecksumData)) { error in
                XCTAssert(error is VerificationError<UInt32>)
            }
        }
    }

    func testCompareWriteData() throws {
        for features in allFeaturesValues {
            let message = WeatherStationUpdate(
                features: features,
                temperature: .init(value: 15, unit: .celsius),
                humidity: 0.6
            )

            XCTAssertEqual(message.data, try message.write())
        }
    }

}
