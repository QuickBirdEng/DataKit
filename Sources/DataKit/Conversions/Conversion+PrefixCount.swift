// Conversion+PrefixCount.swift

import Foundation

extension Conversion where Target: Sequence & Sendable, Target.Element: Sendable {

    /// Wraps the sequence target into a ``PrefixCountArray`` so it can be serialized as a
    /// length-prefixed list. The on-wire layout is: one `Count` integer followed by the
    /// elements.
    public func prefixCount<Count: FixedWidthInteger & Sendable>(
        _ type: Count.Type
    ) -> Appended<PrefixCountArray<Count, Target.Element>> {
        appending { .init(values: .init($0)) }
    }

}

extension Conversion {

    /// Unwraps a ``PrefixCountArray`` back into the underlying collection.
    public func prefixCount<NewTarget: RangeReplaceableCollection & Sendable, Count: FixedWidthInteger & Sendable>(
        _ type: Count.Type
    ) -> Appended<NewTarget> where Target == PrefixCountArray<Count, NewTarget.Element> {
        appending { .init($0.values) }
    }

}

extension ReversibleConversion {

    /// Reversible wrap/unwrap of a `RangeReplaceableCollection` into a ``PrefixCountArray``.
    public func prefixCount<Count: FixedWidthInteger & Sendable>(
        _ type: Count.Type
    ) -> Appended<PrefixCountArray<Count, Target.Element>> where Target: RangeReplaceableCollection & Sendable, Target.Element: Sendable {
        appending {
            $0.prefixCount(Count.self)
        } revert: {
            $0.prefixCount(Count.self)
        }
    }

}

/// A length-prefixed array.
///
/// On the wire: one `Count` integer (in the current environment endianness) followed by
/// exactly that many `Element`s. The count is computed from `values.count` via
/// `Int(exactly:)` semantics on write — values whose count cannot be represented in `Count`
/// throw ``ConversionError``.
public struct PrefixCountArray<Count: FixedWidthInteger, Element> {

    // MARK: Stored Properties

    /// The underlying elements.
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

extension PrefixCountArray: Sendable where Count: Sendable, Element: Sendable {}
