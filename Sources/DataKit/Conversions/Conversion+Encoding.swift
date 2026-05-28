// Conversion+Encoding.swift

import Foundation

extension Conversion where Target: StringProtocol {

    /// Encodes the current string target into `Data` using the given string encoding.
    ///
    /// - Parameters:
    ///   - encoding: The string encoding to use (e.g. `.utf8`, `.ascii`).
    ///   - allowLossyConversion: When `true`, characters that can't be represented are
    ///     replaced rather than failing.
    /// - Throws: ``ConversionError`` if the string cannot be encoded.
    public func encoded(_ encoding: String.Encoding, allowLossyConversion: Bool = false) -> Appended<Data> {
        appending { string in
            guard let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) else {
                throw ConversionError(source: string, targetType: Data.self)
            }
            return data
        }
    }

}

extension Conversion where Target: Sequence<UInt8> {

    /// Decodes the current byte-sequence target into a `String` using the given encoding.
    ///
    /// - Throws: ``ConversionError`` if the bytes cannot be decoded as `encoding`.
    public func encoded(_ encoding: String.Encoding) -> Appended<String> {
        appending { bytes in
            guard let string = String(bytes: bytes, encoding: encoding) else {
                throw ConversionError(source: bytes, targetType: String.self)
            }
            return string
        }
    }

}

extension ReversibleConversion where Target == String {

    /// Two-way string ↔ data encoding using the same `String.Encoding` in both directions.
    /// `allowLossyConversion` applies only to the string-to-data direction.
    public func encoded(_ encoding: String.Encoding, allowLossyConversion: Bool = false) -> Appended<Data> {
        appending {
            $0.encoded(encoding, allowLossyConversion: allowLossyConversion)
        } revert: {
            $0.encoded(encoding)
        }
    }

}
