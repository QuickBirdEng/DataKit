//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.06.23.
//

import Foundation

public struct Checksum<Algorithm: ChecksumAlgorithm, Root, Format: FormatType>: FormatProperty where Format.Root == Root {

    // MARK: Stored Properties

    internal let format: Format

}

extension Checksum where Root: Readable, Format == ReadFormat<Root> {
    public init(_ algorithm: Algorithm) where Algorithm.Value: Readable {
        self.format = .init { container, context in
            let data = container.data[..<container.index]
            let actualValue = try Algorithm.Value(from: &container)
            if !container.environment.skipChecksumVerification {
                try algorithm.verify(actualValue, for: data)
            }
        }
    }
}

extension Checksum where Root: Writable, Format == WriteFormat<Root> {
    public init(_ algorithm: Algorithm) where Algorithm.Value: Writable {
        self.format = .init { container, _ in
            let value = try algorithm.calculate(for: container.data)
            try value.write(to: &container)
        }
    }
}

extension Checksum where Root: ReadWritable, Format == ReadWriteFormat<Root> {
    public init(_ algorithm: Algorithm) where Algorithm.Value: ReadWritable {
        self.format = .init { container, context in
            let data = container.data[..<container.index]
            let actualValue = try Algorithm.Value(from: &container)
            if !container.environment.skipChecksumVerification {
                try algorithm.verify(actualValue, for: data)
            }
        } write: { container, _ in
            let value = try algorithm.calculate(for: container.data)
            try value.write(to: &container)
        }
    }
}

extension Checksum: ReadableProperty where Format: ReadableProperty {
    public func read(from container: inout ReadContainer, context: inout ReadContext<Root>) throws {
        try format.read(from: &container, context: &context)
    }
}

extension Checksum: WritableProperty where Format: WritableProperty {
    public func write(to container: inout WriteContainer, using root: Root) throws {
        try format.write(to: &container, using: root)
    }
}

extension Checksum: ReadWritableProperty where Format: ReadWritableProperty {}
