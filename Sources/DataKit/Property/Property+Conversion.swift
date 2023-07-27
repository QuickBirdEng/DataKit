//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.07.23.
//

import Foundation

extension Property where Root: Readable {

    public func conversion<ConvertedValue: Readable>(
        _ makeConversion: UnidirectionalConversion<ConvertedValue, Value>.Make
    ) -> ReadFormat<Root> {
        converted(UnidirectionalConversion.make(makeConversion).convert)
    }

    public func converted<ConvertedValue: Readable>(
        _ convert: @escaping (ConvertedValue) throws -> Value
    ) -> ReadFormat<Root> {
        ReadFormat { container, context in
            let value = try convert(ConvertedValue(from: &container))
            try context.write(value, for: keyPath)
        }
    }

}

extension Property where Root: Writable {

    public func conversion<ConvertedValue: Writable>(
        _ makeConversion: UnidirectionalConversion<Value, ConvertedValue>.Make
    ) -> WriteFormat<Root> {
        converted(UnidirectionalConversion.make(makeConversion).convert)
    }

    public func converted<ConvertedValue: Writable>(
        _ convert: @escaping (Value) throws -> ConvertedValue
    ) -> WriteFormat<Root> {
        WriteFormat { container, root in
            try convert(root[keyPath: keyPath]).write(to: &container)
        }
    }

}

extension Property where Root: ReadWritable {

    public func conversion<ConvertedValue: ReadWritable>(
        _ makeConversion: BidirectionalConversion<Value, ConvertedValue>.Make
    ) -> ReadWriteFormat<Root> {
        let conversion = BidirectionalConversion.make(makeConversion)
        return converted(reading: conversion.convert, writing: conversion.convert)
    }

    public func converted<ConvertedValue: ReadWritable>(
        reading: @escaping (ConvertedValue) throws -> Value,
        writing: @escaping (Value) throws -> ConvertedValue
    ) -> ReadWriteFormat<Root> {
        ReadWriteFormat(
            read: converted(reading),
            write: converted(writing)
        )
    }

}
