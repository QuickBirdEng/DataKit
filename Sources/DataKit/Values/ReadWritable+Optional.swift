//
//  File.swift
//  
//
//  Created by Paul Kraft on 16.07.23.
//

import Foundation

extension Optional: Readable where Wrapped: Readable {

    public init(from context: ReadContext<Self>) throws {
        self = try context.read(for: \.self)
    }

    public static var readFormat: ReadFormat<Self> {
        ReadFormat { container, context in
            try context.write(.some(Wrapped(from: &container)), for: \.self)
        }
    }

}

extension Optional: Writable where Wrapped: Writable {

    public static var writeFormat: WriteFormat<Self> {
        WriteFormat { container, value in
            try value?.write(to: &container)
        }
    }

}

extension Optional: ReadWritable where Wrapped: ReadWritable {

    public static var format: Format {
        Format(read: readFormat, write: writeFormat)
    }

}
