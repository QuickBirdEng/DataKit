import XCTest
import DataKit

final class DataBuilderTests: XCTestCase {

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let original = MyItem(id: 5, nestedItems: [])
        let data = try original.write()
        let read = try MyItem(data)
        print(data.map { String(format: "%02hhx", $0) }.joined())
        print(original, read)
    }

    func testExample2() throws {
        let original = MyItem(id: 10, nestedItems: [.init(id: 2, value: -15.3)])
        let data = try original.write()
        let read = try MyItem(data) { $0.endianness = .big }
        print(data.map { String(format: "%02hhx", $0) }.joined())
        print(original)
        print(read)
        XCTAssertEqual(original, read)
    }

    func testExample2Directly() throws {
        var environment = EnvironmentValues()
        environment.endianness = .little
        var writeContainer = WriteContainer(environment: environment)

        let value: Double = 124
        try value.write(to: &writeContainer)
        var readContainer = ReadContainer(data: writeContainer.data, environment: environment)
        XCTAssertEqual(value, try .init(from: &readContainer))
    }

    func testExample3() throws {
        let values = (0..<100).map { _ in Double.random(in: -500...500) }

        for value in values {
            XCTAssertEqual(value, Double(bitPattern: value.bitPattern))
            XCTAssertEqual(value, Double(bitPattern: UInt64(littleEndian: value.bitPattern.littleEndian)))
            XCTAssertEqual(value, Double(bitPattern: UInt64(bigEndian: value.bitPattern.bigEndian)))
        }
    }

    func testDataBuilder() throws {
        let value = WeatherStationUpdate(features: [.hasTemperature, .usesMetricUnits], temperature: .init(value: 15, unit: .celsius), humidity: 0.6)
        print(value.data.map { String(format: "%02hhx", $0) }.joined())

        print("hallo".utf8.map { String(format: "%02hhx", $0) }.joined())
    }

}
