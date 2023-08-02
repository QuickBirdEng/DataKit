//
//  File.swift
//
//
//  Created by Paul Kraft on 25.07.23.
//

import DataKit

struct WeatherStationFeatures: OptionSet, ReadWritable {
    var rawValue: UInt8

    static var hasTemperature = Self(rawValue: 1 << 0)
    static var hasHumidity = Self(rawValue: 1 << 1)
    static var usesMetricUnits = Self(rawValue: 1 << 2)
}

struct WeatherStationUpdate {

    var features: WeatherStationFeatures
    var temperature: Measurement<UnitTemperature>
    var humidity: Double

}

extension WeatherStationUpdate {

    @DataBuilder var data: Data {
        UInt8(0x02).bigEndian
        features
        if features.contains(.hasTemperature) {
            Float(temperature.converted(to: features.contains(.usesMetricUnits) ? .celsius : .fahrenheit).value)
        }
        if features.contains(.hasHumidity) {
            UInt8(humidity * 100)
        }
        CRC32.default
    }

}

extension WeatherStationUpdate: ReadWritable {

    init(from context: ReadContext<WeatherStationUpdate>) throws {
        features = try context.read(for: \.features)
        temperature = try context.readIfPresent(for: \.temperature) ?? .init(value: .nan, unit: .kelvin)
        humidity = try context.readIfPresent(for: \.humidity) ?? .nan
    }

    static var format: Format {
        Scope {
            UInt8(0x02)

            \.features

            Using(\.features) { features in
                if features.contains(.hasTemperature) {
                    let unit: UnitTemperature =
                    features.contains(.usesMetricUnits) ? .celsius : .fahrenheit
                    Convert(\.temperature) {
                        $0.converted(to: unit).cast(Float.self)
                    }
                }
                if features.contains(.hasHumidity) {
                    Convert(\.humidity) {
                        Double($0) / 100
                    } writing: {
                        UInt8($0 * 100)
                    }
                }
            }

            CRC32.default
        }
        .endianness(.big)
    }

}

