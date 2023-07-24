//
//  File.swift
//  
//
//  Created by Paul Kraft on 22.06.23.
//

import Foundation

public protocol ReadWritable: Readable, Writable {

    @FormatBuilder
    static var format: Format { get throws }

}

extension ReadWritable {

    public typealias FormatBuilder = ReadWriteFormatBuilder<Self>
    public typealias Format = ReadWriteFormat<Self>

    public static var readFormat: ReadFormat<Self> {
        get throws {
            try ReadFormat(read: format.read)
        }
    }

    public static var writeFormat: WriteFormat<Self> {
        get throws {
            try WriteFormat(write: format.write)
        }
    }

}
