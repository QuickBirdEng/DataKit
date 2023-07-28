//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension Conversion where Target: Sequence {

    public var dynamicCount: Appended<DynamicCountArray<Target.Element>> {
        appending { .init($0) }
    }

}

extension Conversion {

    public func dynamicCount<NewTarget: RangeReplaceableCollection>(
        _ target: NewTarget.Type = NewTarget.self
    ) -> Appended<NewTarget> where Target == DynamicCountArray<NewTarget.Element> {
        appending { NewTarget($0.values) }
    }

}

extension ReversibleConversion where Target: RangeReplaceableCollection {

    public var dynamicCount: Appended<DynamicCountArray<Target.Element>> {
        appending {
            $0.dynamicCount
        } revert: {
            $0.dynamicCount()
        }
    }

}

public struct DynamicCountArray<Element> {

    // MARK: Stored Properties

    public let values: [Element]

    // MARK: Initialization

    public init<S: Sequence<Element>>(_ values: S) {
        self.values = Array(values)
    }

}

extension DynamicCountArray: Readable where Element: Readable {

    public init(from context: ReadContext<Self>) throws {
        self.values = try context.read(for: \.values)
    }

    public static var readFormat: ReadFormat<Self> {
        ReadFormat { container, context in
            var values = [Element]()

            if let suffix = container.environment.suffix {
                while !container.data[container.index...].starts(with: suffix) {
                    try values.append(Element(from: &container))
                }
                _ = try container.consume(suffix.count)
            } else {
                while !container.data[container.index...].isEmpty {
                    try values.append(Element(from: &container))
                }
            }
            try context.write(values, for: \.values)
        }
    }

}

extension DynamicCountArray: Writable where Element: Writable {

    public static var writeFormat: WriteFormat<Self> {
        WriteFormat { container, root in
            for value in root.values {
                try value.write(to: &container)
            }

            if let suffix = container.environment.suffix {
                container.append(suffix)
            }
        }
    }

}

extension DynamicCountArray: ReadWritable where Element: ReadWritable {

    public static var format: Format {
        Format(read: readFormat, write: writeFormat)
    }

}
