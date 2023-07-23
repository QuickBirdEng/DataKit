//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension UnidirectionalConversion where Source: Sequence, Target == VariableLengthArray<Source.Element> {

    public static var variableCount: Self {
        .init {
            .init(Array($0))
        }
    }

}

extension UnidirectionalConversion where Source: Sequence {

    public static func variableCount<Element>(
        as elementConversion: UnidirectionalConversion<Source.Element, Element>
    ) -> Self where Target == VariableLengthArray<Element> {
        .init {
            try VariableLengthArray(
                $0.map { try elementConversion.convert($0) }
            )
        }
    }

}

extension UnidirectionalConversion where Target: RangeReplaceableCollection, Source == VariableLengthArray<Target.Element> {

    public static var variableCount: Self {
        .init {
            .init($0.values)
        }
    }

}

extension UnidirectionalConversion where Target: RangeReplaceableCollection {

    public static func variableCount<Element>(
        as elementConversion: UnidirectionalConversion<Element, Target.Element>
    ) -> Self where Source == VariableLengthArray<Element> {
        .init {
            try .init(
                $0.values.map {
                    try elementConversion.convert($0)
                }
            )
        }
    }

}

extension BidirectionalConversion where Source: RangeReplaceableCollection, Target == VariableLengthArray<Source.Element> {

    public static var variableCount: Self {
        .init(
            forward: .variableCount,
            backward: .variableCount
        )
    }

}

extension BidirectionalConversion where Source: RangeReplaceableCollection {

    public static func variableCount<Element>(
        as elementConversion: BidirectionalConversion<Source.Element, Element>
    ) -> Self where Target == VariableLengthArray<Element> {

        .init(
            forward: .variableCount(as: elementConversion.forwardConversion),
            backward: .variableCount(as: elementConversion.backwardConversion)
        )
    }

}

public struct VariableLengthArray<Element> {

    // MARK: Stored Properties

    public let values: [Element]

    // MARK: Initialization

    public init(_ values: [Element]) {
        self.values = values
    }

}

extension VariableLengthArray: Readable where Element: Readable {

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
            } else {
                while !container.data[container.index...].isEmpty {
                    try values.append(Element(from: &container))
                }
            }
            try context.write(values, for: \.values)
        }
    }

}

extension VariableLengthArray: Writable where Element: Writable {

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

extension VariableLengthArray: ReadWritable where Element: ReadWritable {

    public static var format: Format {
        Format { container, context in
            var values = [Element]()

            if let suffix = container.environment.suffix {
                while !container.data[container.index...].starts(with: suffix) {
                    try values.append(Element(from: &container))
                }
            } else {
                while container.index != container.data.endIndex {
                    try values.append(Element(from: &container))
                }
            }
            try context.write(values, for: \.values)
        } write: { container, root in
            for value in root.values {
                try value.write(to: &container)
            }

            if let suffix = container.environment.suffix {
                container.append(suffix)
            }
        }
    }

}
