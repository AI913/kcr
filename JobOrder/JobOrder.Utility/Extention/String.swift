//
//  String.swift
//  JobOrder.Utility
//
//  Created by Kento Tatsumi on 2020/03/05.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation
import CommonCrypto

/// https://qiita.com/tattn/items/ff50e575bc149ecb8e80
extension String {

    public var localized: String {
        NSLocalizedString(self, comment: self)
    }

    func localized(withTableName tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "") -> String {
        NSLocalizedString(self, tableName: tableName, bundle: bundle, value: value, comment: self)
    }
}

/// https://dishware.sakura.ne.jp/swift/archives/243
extension String {

    // var md5:    String { return digest(string: self, algorithm: .MD5) }
    var sha1: String { return digest(string: self, algorithm: .SHA1) }
    var sha224: String { return digest(string: self, algorithm: .SHA224) }
    public var sha256: String { return digest(string: self, algorithm: .SHA256) }
    var sha384: String { return digest(string: self, algorithm: .SHA384) }
    public var sha512: String { return digest(string: self, algorithm: .SHA512) }

    private func digest(string: String, algorithm: CryptoAlgorithm) -> String {
        var result: [CUnsignedChar]
        let digestLength = Int(algorithm.digestLength)
        if let cdata = string.cString(using: String.Encoding.utf8) {
            result = Array(repeating: 0, count: digestLength)
            switch algorithm {
            // case .MD5:      CC_MD5(cdata, CC_LONG(cdata.count-1), &result)
            case .SHA1:     CC_SHA1(cdata, CC_LONG(cdata.count - 1), &result)
            case .SHA224:   CC_SHA224(cdata, CC_LONG(cdata.count - 1), &result)
            case .SHA256:   CC_SHA256(cdata, CC_LONG(cdata.count - 1), &result)
            case .SHA384:   CC_SHA384(cdata, CC_LONG(cdata.count - 1), &result)
            case .SHA512:   CC_SHA512(cdata, CC_LONG(cdata.count - 1), &result)
            }
        } else {
            fatalError("Nil returned when processing input strings as UTF8")
        }
        return (0..<digestLength).reduce("") { $0 + String(format: "%02hhx", result[$1]) }
    }

    private enum CryptoAlgorithm {

        case /*MD5,*/ SHA1, SHA224, SHA256, SHA384, SHA512

        var digestLength: Int {
            var result: Int32 = 0
            switch self {
            // case .MD5:      result = CC_MD5_DIGEST_LENGTH
            case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
            case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
            case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
            case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
            case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
            }
            return Int(result)
        }
    }
}

// https://github.com/awslabs/amazon-kinesis-video-streams-webrtc-sdk-ios
extension String {

    public func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    public func base64Decoded() -> String? {
        var localData: Data?
        localData = Data(base64Encoded: self)
        var temp = self
        if localData == nil {
            temp = self + "=="
        }
        guard let data = Data(base64Encoded: temp, options: Data.Base64DecodingOptions(rawValue: 0)) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    public func convertToDictionaryValueAsString() throws -> [String: String] {
        let data = Data(utf8)

        if let anyResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
            return anyResult
        } else {
            return [:]
        }
    }

    public func convertToDictionary() throws -> [String: Any] {
        let data = Data(utf8)

        if let anyResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return anyResult
        } else {
            return [:]
        }
    }

    public func trim() -> String {
        return trimmingCharacters(in: .whitespaces)
    }

    public func hmac(keyString: String) -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyString, keyString.count, self, count, &digest)
        return Data(digest)
    }

    public func hmac(keyData: Data) -> Data {
        let keyBytes = keyData.bytes()
        let data = cString(using: String.Encoding.utf8)
        let dataLen = Int(lengthOfBytes(using: String.Encoding.utf8))
        var result = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyBytes, keyData.count, data, dataLen, &result)
        return Data(result)
    }
}

extension Data {

    public func toHexString() -> String {
        let hexString = map { String(format: "%02x", $0) }.joined()
        return hexString
    }

    func bytes() -> [UInt8] {
        let array = [UInt8](self)
        return array
    }
}

/// https://qiita.com/KikurageChan/items/807e84e3fa68bb9c4de6
extension String {
    // 絵文字など(2文字分)も含めた文字数を返します
    var length: Int {
        let string_NS = self as NSString
        return string_NS.length
    }

    // 正規表現の検索をします
    public func pregMatche(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.length))
        return !matches.isEmpty
    }

    // 正規表現の検索結果を利用できます
    public func pregMatche(pattern: String, options: NSRegularExpression.Options = [], matches: inout [String]) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        let targetStringRange = NSRange(location: 0, length: self.length)
        let results = regex.matches(in: self, options: [], range: targetStringRange)
        for i in 0 ..< results.count {
            for j in 0 ..< results[i].numberOfRanges {
                let range = results[i].range(at: j)
                matches.append((self as NSString).substring(with: range))
            }
        }
        return !results.isEmpty
    }

    // 正規表現の置換をします
    public func pregReplace(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: self.length), withTemplate: with)
    }
}
