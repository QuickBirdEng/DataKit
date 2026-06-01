// Conversion+VariableCount.swift

import Foundation

extension Conversion where Target: Sequence & Sendable, Target.Element: Sendable {

    /// Wraps the sequence target into a ``DynamicCountArray`` — a variable-length list whose
    /// boundary is determined by either ``EnvironmentValues/suffix`` or the surrounding
    /// container's bounds, rather than by an explicit length prefix.
    public var dynamicCount: Appended<DynamicCountArray<Target.Element>> {
        appending { .init($0) }
    }

}

extension Conversion {

    /// Unwraps a ``DynamicCountArray`` back into a `RangeReplaceableCollection`.
    public func dynamicCount<NewTarget: RangeReplaceableCollection & Sendable>(
        _ target: NewTarget.Type = NewTarget.self
    ) -> Appended<NewTarget> where Target == DynamicCountArray<NewTarget.Element> {
        appending { NewTarget($0.values) }
    }

}

extension ReversibleConversion where Target: RangeReplaceableCollection & Sendable, Target.Element: Sendable {

    /// Reversible wrap/unwrap of a `RangeReplaceableCollection` into a ``DynamicCountArray``.
    public var dynamicCount: Appended<DynamicCountArray<Target.Element>> {
        appending {
            $0.dynamicCount
        } revert: {
            $0.dynamicCount()
        }
    }

}

/// A variable-length array whose extent is determined at runtime rather than by a length
/// prefix.
///
/// Reading behavior depends on the active ``EnvironmentValues/suffix`` value:
///
/// - If `suffix` is `nil`, elements are read until the container is exhausted.
/// - If `suffix.isRequired == true`, elements are read until the upcoming bytes match the
///   terminator, which is then consumed. If the stream ends before the terminator is found,
///   the inner element read raises ``ReadContainer/LengthExceededError``.
/// - If `suffix.isRequired == false`, reading also stops at EOF.
///
/// On write, the terminator (if any) is appended after the elements.
public struct DynamicCountArray<Element> {

    // MARK: Stored Properties

    /// The underlying elements.
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
                while !(suffix.isRequired ? false : container.remainingData.isEmpty) && !container.remainingData.starts(with: suffix.data) {
                    try values.append(Element(from: &container))
                }
                if !container.remainingData.isEmpty {
                    _ = try container.consume(suffix.data.count)
                }
            } else {
                while !container.remainingData.isEmpty {
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
                container.append(suffix.data)
            }
        }
    }

}

extension DynamicCountArray: ReadWritable where Element: ReadWritable {

    public static var format: Format {
        Format(read: readFormat, write: writeFormat)
    }

}

extension DynamicCountArray: Sendable where Element: Sendable {}
