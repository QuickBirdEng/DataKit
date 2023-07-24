//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension UnidirectionalConversion {

    public static func prefixCount<Count: FixedWidthInteger>(
        _ type: Count.Type
    ) -> Self where Source: Sequence, Target == CountPrefixArray<Count, Source.Element> {
        .init { .init(values: .init($0)) }
    }

    public static func prefixCount<Count: FixedWidthInteger>(
        _ type: Count.Type
    ) -> Self where Target: RangeReplaceableCollection, Source == CountPrefixArray<Count, Target.Element> {
        .init { .init($0.values) }
    }

    public static func prefixCount<Count: FixedWidthInteger, Element>(
        _ type: Count.Type,
        as elementConversion: UnidirectionalConversion<Source.Element, Element>
    ) -> Self where Source: Sequence, Target == CountPrefixArray<Count, Element> {
        .init { try .init(values: .init($0.map { try elementConversion.convert($0) })) }
    }

    public static func prefixCount<Count: FixedWidthInteger, Element>(
        _ type: Count.Type,
        as elementConversion: UnidirectionalConversion<Element, Target.Element>
    ) -> Self where Target: RangeReplaceableCollection, Source == CountPrefixArray<Count, Element> {
        .init { try .init($0.values.map { try elementConversion.convert($0) }) }
    }

}

extension BidirectionalConversion {

    public static func prefixCount<Count: FixedWidthInteger>(
        _ type: Count.Type
    ) -> Self where Source: RangeReplaceableCollection, Target == CountPrefixArray<Count, Source.Element> {
        .init(forward: .prefixCount(Count.self), backward: .prefixCount(Count.self))
    }

    public static func prefixCount<Count: FixedWidthInteger, Element>(
        _ type: Count.Type,
        as elementConversion: BidirectionalConversion<Source.Element, Element>
    ) -> Self where Source: RangeReplaceableCollection, Target == CountPrefixArray<Count, Element> {
        .init(
            forward: .prefixCount(Count.self, as: elementConversion.forwardConversion),
            backward: .prefixCount(Count.self, as: elementConversion.backwardConversion)
        )
    }

}

public struct CountPrefixArray<Count: FixedWidthInteger, Element> {

    // MARK: Stored Properties

    public let values: [Element]

    // MARK: Initialization

    public init(values: [Element]) {
        self.values = values
    }

}

extension CountPrefixArray: Readable where Count: Readable, Element: Readable {

    public init(from context: ReadContext<Self>) throws {
        let count = try context.read(for: \.values.count)
        self.values = try (0..<count).map { index in try context.read(for: \.values[index]) }
    }

    public static var readFormat: ReadFormat<Self> {
        Property(\.values.count, as: .exactly(from: Count.self))

        Using(\.values.count) { count in
            for index in 0..<count {
                Property(\.values[index])
            }
        }
    }

}

extension CountPrefixArray: Writable where Count: Writable, Element: Writable {

    public static var writeFormat: WriteFormat<Self> {
        Property(\.values.count, as: .exactly(to: Count.self))

        Using(\.values.count) { count in
            for index in 0..<count {
                Property(\.values[index])
            }
        }
    }

}

extension CountPrefixArray: ReadWritable where Count: ReadWritable, Element: ReadWritable {

    public static var format: Format {
        Property(\.values.count, as: .exactly(Count.self))

        Using(\.values.count) { count in
            for index in 0..<count {
                Property(\.values[index])
            }
        }
    }

}
