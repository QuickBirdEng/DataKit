//
//  File.swift
//  
//
//  Created by Paul Kraft on 24.06.23.
//

import Foundation

public protocol EnvironmentKey {
    associatedtype Value

    static var defaultValue: Value { get }
}

public struct EnvironmentValues {

    // MARK: Stored Properties

    private var values = [ObjectIdentifier: Any]()

    // MARK: Initialization

    public init() {}

    // MARK: Methods

    public subscript<Key: EnvironmentKey>(_ key: Key.Type) -> Key.Value {
        get { values[ObjectIdentifier(Key.self), default: Key.defaultValue] as! Key.Value }
        set { values[ObjectIdentifier(Key.self)] = newValue }
    }

}
