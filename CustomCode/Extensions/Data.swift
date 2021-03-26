// Copyright © 2017-2020 Trust Wallet.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

extension Data {

    var keccak256: String {
        guard let string = string(encoding: .utf8) else { return "" }
        return (string as NSString).keccak256()
    }

}

extension Data {
    /// Initializes `Data` with a hex string representation.
    public init?(hexString: String) {
        let string: String
        if hexString.hasPrefix("0x") {
            string = String(hexString.dropFirst(2))
        } else {
            string = hexString
        }

        // Check odd length hex string
        if string.count % 2 != 0 {
            return nil
        }

        // Convert the string to bytes for better performance
        guard let stringData = string.data(using: .ascii, allowLossyConversion: true) else {
            return nil
        }

        self.init(capacity: string.count / 2)
        let stringBytes = Array(stringData)
        for i in stride(from: 0, to: stringBytes.count, by: 2) {
            guard let high = Data.value(of: stringBytes[i]) else {
                return nil
            }
            if i < stringBytes.count - 1, let low = Data.value(of: stringBytes[i + 1]) {
                append((high << 4) | low)
            } else {
                append(high)
            }
        }
    }

    /// Converts an ASCII byte to a hex value.
    private static func value(of nibble: UInt8) -> UInt8? {
        guard let letter = String(bytes: [nibble], encoding: .ascii) else { return nil }
        return UInt8(letter, radix: 16)
    }

    /// Returns the hex string representation of the data.
    public var hexString: String {
        return map({ String(format: "%02x", $0) }).joined()
    }
    
}

public extension KeyedDecodingContainerProtocol {
    func decodeHexString(forKey key: Self.Key) throws -> Data {
        let hexString = try decode(String.self, forKey: key)
        guard let data = Data(hexString: hexString) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Expected hexadecimal string")
        }
        return data
    }

    func decodeHexStringIfPresent(forKey key: Self.Key) throws -> Data? {
        guard let hexString = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        guard let data = Data(hexString: hexString) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Expected hexadecimal string")
        }
        return data
    }
}

public extension Data {
    /// SwifterSwift: Return data as an array of bytes.
    var bytes: [UInt8] {
        // http://stackoverflow.com/questions/38097710/swift-3-changes-for-getbytes-method
        return [UInt8](self)
    }
}

// MARK: - Methods

public extension Data {
    func string(encoding: String.Encoding) -> String? {
        return String(data: self, encoding: encoding)
    }

    func jsonObject(options: JSONSerialization.ReadingOptions = []) throws -> Any {
        return try JSONSerialization.jsonObject(with: self, options: options)
    }
}
