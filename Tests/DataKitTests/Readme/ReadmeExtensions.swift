//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.07.23.
//

import DataKit

extension WeatherStationUpdate {

    init(temperature: Double? = nil, unit: UnitTemperature = .fahrenheit, humidity: Double? = nil) {
        self.init(
            features: [
                temperature != nil ? .hasTemperature : [],
                humidity != nil ? .hasHumidity : [],
                unit != .fahrenheit ? .usesMetricUnits : [],
            ],
            temperature: .init(value: temperature ?? .nan, unit: unit),
            humidity: humidity ?? .nan
        )
    }

}

extension WeatherStationUpdate: Equatable {

    static func == (lhs: WeatherStationUpdate, rhs: WeatherStationUpdate) -> Bool {
        guard lhs.features.rawValue == rhs.features.rawValue else {
            return false
        }
        if lhs.features.contains(.hasTemperature) {
            guard lhs.temperature.unit == rhs.temperature.unit && lhs.temperature.value == rhs.temperature.value else {
                return false
            }
        } else {
            guard lhs.temperature.value.isNaN && rhs.temperature.value.isNaN else {
                return false
            }
        }
        if lhs.features.contains(.hasHumidity) {
            guard lhs.humidity == rhs.humidity else {
                return false
            }
        } else {
            guard lhs.humidity.isNaN && rhs.humidity.isNaN else {
                return false
            }
        }
        return true
    }

}
