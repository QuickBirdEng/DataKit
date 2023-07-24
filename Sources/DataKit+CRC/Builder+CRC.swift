//
//  File.swift
//  
//
//  Created by Paul Kraft on 23.07.23.
//

import CRC
import DataKit

extension CRC: ChecksumAlgorithm {}

extension FormatBuilder where Format == ReadFormat<Root> {
    public static func buildExpression<Value: Readable>(
        _ expression: CRC<Value>
    ) -> Format {
        buildExpression(Checksum(expression))
    }
}

extension FormatBuilder where Format == ReadWriteFormat<Root> {
    public static func buildExpression<Value: ReadWritable>(
        _ expression: CRC<Value>
    ) -> Format {
        buildExpression(Checksum(expression))
    }
}

extension FormatBuilder where Format == WriteFormat<Root> {
    public static func buildExpression<Value: Writable>(
        _ expression: CRC<Value>
    ) -> Format {
        buildExpression(Checksum(expression))
    }
}

extension DataBuilder {
    public static func buildExpression<Value: Writable>(
        _ expression: CRC<Value>
    ) -> Component {
        .init { data in
            let value = expression.calculate(for: data)
            buildExpression(value.bigEndian)
                .append(&data)
        }
    }
}
