//
//  File.swift
//  
//
//  Created by Paul Kraft on 15.07.23.
//

import Foundation

public protocol FormatProperty<Root> {
    associatedtype Root
}

public protocol FormatType<Root>: FormatProperty {
    init(_ multiple: [Self])
}
