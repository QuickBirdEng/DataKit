//
//  File.swift
//
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension Int: ReadWritable {}
extension Int8: ReadWritable {}
extension Int16: ReadWritable {}
extension Int32: ReadWritable {}
extension Int64: ReadWritable {}

extension UInt: ReadWritable {}
extension UInt8: ReadWritable {}
extension UInt16: ReadWritable {}
extension UInt32: ReadWritable {}
extension UInt64: ReadWritable {}

extension FixedWidthInteger where Self: ReadWritable {

    public init(from context: ReadContext<Self>) throws {
        self = try context.read(for: \.self)
    }

    public static var format: Format {
        Format(
            read: .init { container, context in
                var value: Self = 0

                try withUnsafeMutableBytes(of: &value) { bytes in
                    try bytes.copyBytes(
                        from: container.consume(MemoryLayout<Self>.size)
                    )
                }

                let readValue: Self = {
                    switch container.environment.endianness {
                    case .little:
                        return .init(littleEndian: value)
                    case .big:
                        return .init(bigEndian: value)
                    case nil:
                        return value
                    }
                }()

                try context.write(readValue, for: \.self)
            },
            write: .init { container, value in
                let writtenValue: Self = {
                    switch container.environment.endianness {
                    case .little:
                        return value.littleEndian
                    case .big:
                        return value.bigEndian
                    case nil:
                        return value
                    }
                }()

                withUnsafeBytes(of: writtenValue) {
                    container.append(contentsOf: $0)
                }
            }
        )
    }

}


