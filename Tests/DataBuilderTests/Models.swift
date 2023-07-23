//
//  File.swift
//  
//
//  Created by Paul Kraft on 14.07.23.
//

import Foundation
import DataBuilder

struct WeatherStationFeatures: OptionSet {
    var rawValue: UInt8

    static var hasTemperature = Self(rawValue: 1 << 0)
    static var hasHumidity = Self(rawValue: 1 << 1)
    static var usesMetricUnits = Self(rawValue: 1 << 2)
}

struct WeatherStationUpdate {

    var id: UInt16
    var features: WeatherStationFeatures
    var temperature: Double
    var humidity: Double

    @DataBuilder func build() -> Data {
        UInt8(0x02).bigEndian
        id.bigEndian
        features.rawValue
        if features.contains(.hasTemperature) {
            if features.contains(.usesMetricUnits) {
                Float(temperature)
                    .bitPattern
                    .bigEndian
            } else {
                Float(32 + (9 / 5) * temperature)
                    .bitPattern
                    .bigEndian
            }
        }
        if features.contains(.hasHumidity) {
            UInt8(humidity * 100)
        }
        XORChecksum()
    }

}

public struct MyItem: Equatable {

    var id: Int64
    var nestedItems: [MyNestedItem]

}

extension MyItem: ReadWritable {

    public static var format: Format {
        Scope {
            UInt8(0x02)

            /*
            Scope {
                MyNestedItem(id: 2, value: -4)
            }
            .endianness(.big)
*/

            Property(\.id, as: .exactly(UInt16.self))
                .endianness(.big)

            Property(\.nestedItems, as: .prefixCount(UInt8.self))
                // .suffix(UInt64.zero)

            Environment(\.skipChecksumVerification) { value in
                Checksum(.xor)
                    .skipChecksumVerification(!value)
            }
        }
    }

    public init(from context: ReadContext<Self>) throws {
        self.id = try context.read(for: \.id)
        self.nestedItems = try context.read(for: \.nestedItems)
    }

}

public struct MyNestedItem: Equatable {

    var id: Int64
    var value: Double

}

extension MyNestedItem: ReadWritable {

    public init(from context: ReadContext<Self>) throws {
        self.id = try context.read(for: \.id)
        self.value = try context.read(for: \.value)
    }

    public static var format: Format {
        Scope {
            Property(\.id, as: .exactly(UInt16.self))
                .endianness(.big)
            Property(\.value)
                .endianness(.little)
            Checksum(.xor)
        }
    }

}
