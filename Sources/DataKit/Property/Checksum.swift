//
//  File.swift
//  
//
//  Created by Paul Kraft on 31.07.23.
//

import Foundation

public struct ChecksumProperty<ChecksumType: Checksum, Format: FormatType>: FormatProperty {

    // MARK: Nested Types

    public typealias Root = Format.Root
    public typealias Value = ChecksumType.Value

    // MARK: Stored Properties

    internal let format: Format

    // MARK: Initialization

    public init<Root: Readable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, Value>? = nil
    ) where Format == ReadFormat<Root>, ChecksumType.Value: Readable {
        self.format = ReadFormatBuilder.buildExpression(
            ReadFormat { container, context in
                let verificationData = container.consumedData
                let value = try Value(from: &container)
                try checksum.verify(value, for: verificationData)
                if let keyPath {
                    try context.write(value, for: keyPath)
                }
            }
            .endianness(.big)
        )
    }

    public init<Root: Readable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, Value?>? = nil
    ) where Format == ReadFormat<Root>, ChecksumType.Value: Readable {
        self.format = ReadFormatBuilder.buildExpression(
            ReadFormat { container, context in
                let verificationData = container.consumedData
                let value = try Value(from: &container)
                try checksum.verify(value, for: verificationData)
                if let keyPath {
                    try context.write(value, for: keyPath)
                }
            }
            .endianness(.big)
        )
    }

    public init<Root: Writable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, Value>? = nil
    ) where Format == WriteFormat<Root>, ChecksumType.Value: Writable {
        self.format = WriteFormatBuilder.buildExpression(
            WriteFormat { container, root in
                let value = keyPath.map { root[keyPath: $0] }
                    ?? checksum.calculate(for: container.data)
                try value.write(to: &container)
            }
            .endianness(.big)
        )
    }

    public init<Root: Writable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, Value?>? = nil
    ) where Format == WriteFormat<Root>, ChecksumType.Value: Writable {
        self.format = WriteFormatBuilder.buildExpression(
            WriteFormat { container, root in
                let value = keyPath.flatMap { root[keyPath: $0] }
                    ?? checksum.calculate(for: container.data)
                try value.write(to: &container)
            }
            .endianness(.big)
        )
    }

    public init<Root: ReadWritable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, Value>? = nil
    ) where Format == ReadWriteFormat<Root>, ChecksumType.Value: ReadWritable {
        self.format = ReadWriteFormatBuilder.buildExpression(
            ReadWriteFormat(
                read: .init { container, context in
                    let verificationData = container.consumedData
                    let value = try Value(from: &container)
                    try checksum.verify(value, for: verificationData)
                    if let keyPath {
                        try context.write(value, for: keyPath)
                    }
                },
                write: .init { container, root in
                    let value = keyPath.map { root[keyPath: $0] }
                    ?? checksum.calculate(for: container.data)
                    try value.write(to: &container)
                }
            )
            .endianness(.big)
        )
    }

    public init<Root: ReadWritable>(
        _ checksum: ChecksumType,
        at keyPath: KeyPath<Root, Value?>? = nil
    ) where Format == ReadWriteFormat<Root>, ChecksumType.Value: ReadWritable {
        self.format = ReadWriteFormatBuilder.buildExpression(
            ReadWriteFormat(
                read: .init { container, context in
                    let verificationData = container.consumedData
                    let value = try Value(from: &container)
                    try checksum.verify(value, for: verificationData)
                    if let keyPath {
                        try context.write(value, for: keyPath)
                    }
                },
                write: .init { container, root in
                    let value = keyPath.flatMap { root[keyPath: $0] }
                        ?? checksum.calculate(for: container.data)
                    try value.write(to: &container)
                }
            )
            .endianness(.big)
        )
    }

}
