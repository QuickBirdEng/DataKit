//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension RawRepresentable where Self: Readable, RawValue: Readable {

    public init(from context: ReadContext<Self>) throws {
        let rawValue = try context.read(for: \.rawValue)
        guard let value = Self(rawValue: rawValue) else {
            throw ConversionError(source: rawValue, targetType: Self.self)
        }
        self = value
    }

    @ReadBuilder
    public static var readFormat: ReadFormat<Self> {
        Property(\.rawValue)
    }

}

extension RawRepresentable where Self: Writable, RawValue: Writable {

    @WriteBuilder
    public static var writeFormat: WriteFormat<Self> {
        Property(\.rawValue)
    }

}

extension RawRepresentable where Self: ReadWritable, RawValue: ReadWritable {

    @FormatBuilder
    public static var format: Format {
        Property(\.rawValue)
    }

}
