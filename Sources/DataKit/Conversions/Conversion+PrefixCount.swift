//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension UnidirectionalConversion where Target: Sequence {

    public func prefixCount<Count: FixedWidthInteger>(
        _ type: Count.Type
    ) -> Appended<PrefixCountArray<Count, Target.Element>> {
        appending { .init(values: .init($0)) }
    }

}

extension UnidirectionalConversion {

    public func prefixCount<NewTarget: RangeReplaceableCollection, Count: FixedWidthInteger>(
        _ type: Count.Type
    ) -> Appended<NewTarget> where Target == PrefixCountArray<Count, NewTarget.Element> {
        appending { .init($0.values) }
    }

}

extension BidirectionalConversion {

    public func prefixCount<Count: FixedWidthInteger>(
        _ type: Count.Type
    ) -> Appended<PrefixCountArray<Count, Target.Element>> where Target: RangeReplaceableCollection {
        appending {
            $0.prefixCount(Count.self)
        } backward: {
            $0.prefixCount(Count.self)
        }
    }

}

public struct PrefixCountArray<Count: FixedWidthInteger, Element> {

    // MARK: Stored Properties

    public let values: [Element]

    // MARK: Initialization

    public init(values: [Element]) {
        self.values = values
    }

}

extension PrefixCountArray: Readable where Count: Readable, Element: Readable {

    public init(from context: ReadContext<Self>) throws {
        let count = try context.read(for: \.values.count)
        self.values = try (0..<count).map { index in try context.read(for: \.values[index]) }
    }

    public static var readFormat: ReadFormat<Self> {
        Convert(\.values.count) {
            $0.exactly(from: Count.self)
        }

        Using(\.values.count) { count in
            for index in 0..<count {
                \.values[index]
            }
        }
    }

}

extension PrefixCountArray: Writable where Count: Writable, Element: Writable {

    public static var writeFormat: WriteFormat<Self> {
        Property(\.values.count)
            .conversion { $0.exactly(Count.self) }

        Using(\.values.count) { count in
            for index in 0..<count {
                \.values[index]
            }
        }
    }

}

extension PrefixCountArray: ReadWritable where Count: ReadWritable, Element: ReadWritable {

    public static var format: Format {
        Format(read: readFormat, write: writeFormat)
    }

}
