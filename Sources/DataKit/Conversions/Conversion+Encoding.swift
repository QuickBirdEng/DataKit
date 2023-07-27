//
//  File.swift
//  
//
//  Created by Paul Kraft on 26.07.23.
//

import Foundation

extension UnidirectionalConversion where Target: StringProtocol {

    public func encoded(_ encoding: String.Encoding, allowLossyConversion: Bool = false) -> Appended<Data> {
        appending { string in
            guard let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) else {
                throw ConversionError(source: string, targetType: Data.self)
            }
            return data
        }
    }

}

extension UnidirectionalConversion where Target: Sequence<UInt8> {

    public func encoded(_ encoding: String.Encoding) -> Appended<String> {
        appending { bytes in
            guard let string = String(bytes: bytes, encoding: encoding) else {
                throw ConversionError(source: bytes, targetType: String.self)
            }
            return string
        }
    }

}

extension BidirectionalConversion where Target == String {

    public func encoded(_ encoding: String.Encoding, allowLossyConversion: Bool = false) -> Appended<Data> {
        appending {
            $0.encoded(encoding, allowLossyConversion: allowLossyConversion)
        } backward: {
            $0.encoded(encoding)
        }
    }

}
