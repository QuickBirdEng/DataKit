//
//  File.swift
//  
//
//  Created by Paul Kraft on 14.07.23.
//

import Foundation
import DataKit

public struct MyItem: Equatable {

    var id: Int64
    var nestedItems: [MyNestedItem]

}

extension MyItem: ReadWritable {

    public static var format: Format {
        Scope {
            UInt8(0x02)

            Scope {
                MyNestedItem(id: 2, value: -4)
            }
            .endianness(.big)

            Convert(\.id) { $0.exactly(UInt16.self) }
                .endianness(.big)

            Convert(\.nestedItems) { $0.prefixCount(UInt8.self) }

            CRC32.default
        }
    }

    public init(from context: ReadContext<Self>) throws {
        self.id = try context.read(for: \.id)
        self.nestedItems = try context.read(for: \.nestedItems)
    }

}

public struct MyNestedItem: Equatable {

    var id: Int64
    var value: Double

}

extension MyNestedItem: ReadWritable {

    public init(from context: ReadContext<Self>) throws {
        self.id = try context.read(for: \.id)
        self.value = try context.read(for: \.value)
    }

    public static var format: Format {
        Scope {
            Convert(\.id) { $0.exactly(UInt16.self) }
                .endianness(.big)

            Property(\.value)
                .endianness(.little)

            CRC32.default
        }
    }

}
