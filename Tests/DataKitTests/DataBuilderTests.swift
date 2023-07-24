import XCTest
@testable import DataKit

func encodeValues(littleEndianValue: UInt16, bigEndianValue: UInt16, littleEndianDouble: Double, bigEndianDouble: Double) -> Data {
    var data = Data()

    // Encode little endian value
    var littleEndianValue = littleEndianValue.littleEndian
    withUnsafeBytes(of: &littleEndianValue) { bytes in
        data.append(contentsOf: bytes)
    }

    // Encode big endian value
    var bigEndianValue = bigEndianValue.bigEndian
    withUnsafeBytes(of: &bigEndianValue) { bytes in
        data.append(contentsOf: bytes)
    }

    // Encode little endian double
    var littleEndianDouble = littleEndianDouble.bitPattern.littleEndian
    withUnsafeBytes(of: &littleEndianDouble) { bytes in
        data.append(contentsOf: bytes)
    }

    // Encode big endian double
    var bigEndianDouble = bigEndianDouble.bitPattern.bigEndian
    withUnsafeBytes(of: &bigEndianDouble) { bytes in
        data.append(contentsOf: bytes)
    }

    return data
}


func decodeValues(from data: Data) -> (littleEndianValue: UInt16, bigEndianValue: UInt16, littleEndianDouble: Double, bigEndianDouble: Double)? {
    guard data.count >= 16 else {
        return nil
    }

    var littleEndianValue: UInt16 = 0
    var bigEndianValue: UInt16 = 0
    var littleEndianDoubleBits: UInt64 = 0
    var bigEndianDoubleBits: UInt64 = 0

    // Decode little endian value
    withUnsafeMutableBytes(of: &littleEndianValue) { bytes in
        bytes.copyBytes(from: data[..<2])
    }
    littleEndianValue = UInt16(littleEndian: littleEndianValue)

    // Decode big endian value
    withUnsafeMutableBytes(of: &bigEndianValue) { bytes in
        bytes.copyBytes(from: data[2..<4])
    }
    bigEndianValue = UInt16(bigEndian: bigEndianValue)

    // Decode little endian double
    withUnsafeMutableBytes(of: &littleEndianDoubleBits) { bytes in
        bytes.copyBytes(from: data[4..<12])
    }
    littleEndianDoubleBits = UInt64(littleEndian: littleEndianDoubleBits)
    let littleEndianDouble = Double(bitPattern: littleEndianDoubleBits)

    // Decode big endian double
    withUnsafeMutableBytes(of: &bigEndianDoubleBits) { bytes in
        bytes.copyBytes(from: data[12...])
    }
    bigEndianDoubleBits = UInt64(bigEndian: bigEndianDoubleBits)
    let bigEndianDouble = Double(bitPattern: bigEndianDoubleBits)

    return (littleEndianValue, bigEndianValue, littleEndianDouble, bigEndianDouble)
}

final class DataBuilderTests: XCTestCase {

    func testChat() throws {
        for _ in 0..<100 {
            let value0 = UInt16.random(in: UInt16.min...UInt16.max)
            let value1 = UInt16.random(in: UInt16.min...UInt16.max)
            let value2 = Double.random(in: -500...500)
            let value3 = Double.random(in: -500...500)
            let data = encodeValues(littleEndianValue: value0, bigEndianValue: value1, littleEndianDouble: value2, bigEndianDouble: value3)
            let (decoded0, decoded1, decoded2, decoded3) = decodeValues(from: data)!
            XCTAssertEqual(value0, decoded0)
            XCTAssertEqual(value1, decoded1)
            XCTAssertEqual(value2, decoded2)
            XCTAssertEqual(value3, decoded3)
        }
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let original = MyItem(id: 5, nestedItems: [])
        let data = try original.write()
        let read = try MyItem(binary: data)
        print(data.map { String(format: "%02hhx", $0) }.joined())
        print(original, read)
    }

    func testExample2() throws {
        let original = MyItem(id: 10, nestedItems: [.init(id: 2, value: -15.3)])
        let data = try original.write()
        let read = try MyItem(binary: data)
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
        let value = WeatherStationUpdate(id: 1, features: [.hasTemperature, .usesMetricUnits], temperature: 15, humidity: 0.6)
        print(value.id.bigEndian)
        print(value.build().map { String(format: "%02hhx", $0) }.joined())

        print("hallo".utf8.map { String(format: "%02hhx", $0) }.joined())
    }

}
