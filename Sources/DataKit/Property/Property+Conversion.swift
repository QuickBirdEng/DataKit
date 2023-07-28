//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.07.23.
//

import Foundation

extension Property where Root: Readable {

    public func conversion<ConvertedValue: Readable>(
        _ makeConversion: Conversion<ConvertedValue, Value>.Make
    ) -> Convert<ReadFormat<Root>> {
        Convert(keyPath, conversion: makeConversion)
    }

    public func converted<ConvertedValue: Readable>(
        _ convert: @escaping (ConvertedValue) throws -> Value
    ) -> Convert<ReadFormat<Root>> {
        Convert(keyPath, convert: convert)
    }

}

extension Property where Root: Writable {

    public func conversion<ConvertedValue: Writable>(
        _ makeConversion: Conversion<Value, ConvertedValue>.Make
    ) -> Convert<WriteFormat<Root>> {
        Convert(keyPath, conversion: makeConversion)
    }

    public func converted<ConvertedValue: Writable>(
        _ convert: @escaping (Value) throws -> ConvertedValue
    ) -> Convert<WriteFormat<Root>> {
        Convert(keyPath, convert: convert)
    }

}

extension Property where Root: ReadWritable {

    public func conversion<ConvertedValue: ReadWritable>(
        _ makeConversion: ReversibleConversion<Value, ConvertedValue>.Make
    ) -> Convert<ReadWriteFormat<Root>> {
        Convert(keyPath, conversion: makeConversion)
    }

    public func converted<ConvertedValue: ReadWritable>(
        reading: @escaping (ConvertedValue) throws -> Value,
        writing: @escaping (Value) throws -> ConvertedValue
    ) -> Convert<ReadWriteFormat<Root>> {
        Convert(keyPath, reading: reading, writing: writing)
    }

}
