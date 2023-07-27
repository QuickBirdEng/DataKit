//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

public protocol FixedWidthFloatingPoint: BinaryFloatingPoint {
    associatedtype BitPattern: FixedWidthInteger

    init(bitPattern: BitPattern)
    var bitPattern: BitPattern { get }
}

@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
extension Float16: FixedWidthFloatingPoint, ReadWritable {}
extension Float32: FixedWidthFloatingPoint, ReadWritable {}
extension Float64: FixedWidthFloatingPoint, ReadWritable {}

extension FixedWidthFloatingPoint where Self: ReadWritable, BitPattern: ReadWritable {

    public init(from context: ReadContext<Self>) throws {
        try self.init(bitPattern: context.read(for: \.bitPattern))
    }

    @FormatBuilder
    public static var format: Format {
        \.bitPattern
    }

}
