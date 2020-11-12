//
//  KVSSigner.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/02/21.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

// https://github.com/awslabs/amazon-kinesis-video-streams-webrtc-sdk-ios

import CommonCrypto
import Foundation

class KVSSigner {

    static let utcDateFormatter = "yyyyMMdd'T'HHmmss'Z'"
    static let utcTimezone = "UTC"
    static let awsRequestTypeKey = "aws4_request"
    static let signerAlgorithm = "AWS4-HMAC-SHA256"
    static let restMethod = "GET"
    static let awsKinesisVideoKey = "kinesisvideo"
    static let videoProtocols =  ["WSS", "HTTPS"]

    static let slashDelimiter = "/"
    static let plusDelimiter = "+"
    static let equalsDelimiter = "="
    static let newlineDelimiter = "\n"
    static let colonDelimiter = ":"
    static let ampersandDelimiter = "&"

    static let hostKey = "host"
    static let wssKey = "wss"

    static let plusEncoding = "%2B"
    static let equalsEncoding = "%3D"

    static let xAmzAlgorithm = "X-Amz-Algorithm"
    static let xAmzCredential = "X-Amz-Credential"
    static let xAmzDate = "X-Amz-Date"
    static let xAmzExpiresKey = "X-Amz-Expires"
    static let xAmzExpiresValue = "299"
    static let xAmzSecurityToken = "X-Amz-Security-Token"
    static let xAmzSignature = "X-Amz-Signature"
    static let xAmzSignedHeaders = "X-Amz-SignedHeaders"

    static func iso8601() -> (fullDateTimestamp: String, shortDate: String) {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = utcDateFormatter
        dateFormatter.timeZone = TimeZone(abbreviation: utcTimezone)
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        let index = dateString.index(dateString.startIndex, offsetBy: 8)
        let shortDate = String(dateString[..<index])
        return (fullDateTimestamp: dateString, shortDate: shortDate)
    }

    /*
     DateKey              = HMAC-SHA256("AWS4"+"<SecretAccessKey>", "<YYYYMMDD>")
     DateRegionKey        = HMAC-SHA256(<DateKey>, "<aws-region>")
     DateRegionServiceKey = HMAC-SHA256(<DateRegionKey>, "<aws-service>")
     SigningKey           = HMAC-SHA256(<DateRegionServiceKey>, "aws4_request")
     */
    static func signatureWith(stringToSign: String, secretAccessKey: String, shortDateString: String, awsRegion: String, serviceType: String) -> String? {

        let firstKey = "AWS4" + secretAccessKey
        let dateKey = shortDateString.hmac(keyString: firstKey)
        let dateRegionKey = awsRegion.hmac(keyData: dateKey)
        let dateRegionServiceKey = serviceType.hmac(keyData: dateRegionKey)
        let signingKey = awsRequestTypeKey.hmac(keyData: dateRegionServiceKey)

        let signature = stringToSign.hmac(keyData: signingKey)
        return signature.toHexString()
    }

    static func getCredentialScope(shortDate: String, region: String, serviceName: String, requestType: String) -> String {
        let credentialArray = [shortDate, region, serviceName, requestType]
        return credentialArray.joined(separator: slashDelimiter)
    }

    static func getQueryParams(accessKey: String, sessionToken: String, credentialScope: String, date:(fullDateTimestamp: String, shortDate: String)) -> (queryParamBuilder: [URLQueryItem], queryParamBuilderDict: [String: String]) {
        var queryParamsBuilderArray = [URLQueryItem]()
        queryParamsBuilderArray.append(URLQueryItem(name: xAmzAlgorithm, value: signerAlgorithm))
        queryParamsBuilderArray.append(URLQueryItem(name: xAmzCredential, value: (accessKey + slashDelimiter + credentialScope).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!))
        queryParamsBuilderArray.append(URLQueryItem(name: xAmzDate, value: date.fullDateTimestamp))
        queryParamsBuilderArray.append(URLQueryItem(name: xAmzExpiresKey, value: xAmzExpiresValue))
        queryParamsBuilderArray.append(URLQueryItem(name: xAmzSignedHeaders, value: hostKey))

        var queryParamsBuilderDictionary: [String: String] = [
            xAmzAlgorithm: signerAlgorithm,
            xAmzCredential: (accessKey + slashDelimiter + credentialScope).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
            xAmzDate: date.fullDateTimestamp,
            xAmzExpiresKey: xAmzExpiresValue,
            xAmzSignedHeaders: hostKey
        ]

        if !sessionToken.isEmpty {
            queryParamsBuilderArray
                .append(URLQueryItem(
                            name: xAmzSecurityToken,
                            value: sessionToken.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!.replacingOccurrences(of: plusDelimiter, with: plusEncoding).replacingOccurrences(of: equalsDelimiter, with: equalsEncoding)))
            queryParamsBuilderDictionary
                .updateValue(sessionToken.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!.replacingOccurrences(of: plusDelimiter, with: plusEncoding).replacingOccurrences(of: equalsDelimiter, with: equalsEncoding),
                             forKey: xAmzSecurityToken)
        }

        return (queryParamsBuilderArray, queryParamsBuilderDictionary)
    }

    static func getStringToSign(fullDateTimeStamp: String, credentialScope: String, canonicalRequest: String) -> String {
        return signerAlgorithm + newlineDelimiter +
            fullDateTimeStamp + newlineDelimiter +
            credentialScope + newlineDelimiter +
            canonicalRequest.sha256
    }

    static func getSignedUrl(wssRequest: URL, queryParamsBuilder: [URLQueryItem], canonicalUri: String, signature: String) -> URL? {

        var components = URLComponents()
        components.scheme = wssKey
        components.host = wssRequest.host
        components.path = canonicalUri
        var queryParamsBuilderArray = queryParamsBuilder
        queryParamsBuilderArray.sort {
            $0.name < $1.name
        }
        queryParamsBuilderArray.append(URLQueryItem(name: xAmzSignature, value: signature))

        if #available(iOS 11.0, *) {
            components.percentEncodedQueryItems = queryParamsBuilderArray
        } else {

        }
        print("Signed url", components.url!)
        return components.url
    }

    static func getCanonicalHeaders(signRequest: URL) -> String? {
        guard let host = signRequest.host
        else { return .none }
        return hostKey + colonDelimiter + host + newlineDelimiter
    }

    static func getCanonicalUri (signRequest: URL) -> String? {
        if signRequest.path.isEmpty {
            return slashDelimiter
        }
        return signRequest.path
    }

    static func getCanonicalRequest(canonicalQuerystring: String, signRequest: URL) -> String? {
        let cleanedcanonicalQuerystring = String(canonicalQuerystring.dropLast())
        let emptyString = ""
        let payloadHash = emptyString.sha256
        return
            restMethod + newlineDelimiter +
            getCanonicalUri(signRequest: signRequest)! + newlineDelimiter +
            cleanedcanonicalQuerystring + newlineDelimiter +
            getCanonicalHeaders(signRequest: signRequest)! + newlineDelimiter +
            hostKey + newlineDelimiter + payloadHash
    }

    static func getCanonicalQueryString(queryParamBuilderDict: [String: String]) -> String? {
        let sortedKeys = queryParamBuilderDict.keys.sorted()
        var canonicalQueryString: String = ""

        for key in sortedKeys {
            canonicalQueryString += key + equalsDelimiter + queryParamBuilderDict[key]! + ampersandDelimiter
        }
        return canonicalQueryString
    }

    static func sign(signRequest: URL, secretKey: String, accessKey: String, sessionToken: String,
                     wssRequest: URL, region: String) -> URL? {
        let date = iso8601()
        return signWithDate(signRequest: signRequest, secretKey: secretKey, accessKey: accessKey, sessionToken: sessionToken, wssRequest: wssRequest, region: region, date: date)
    }

    static func signWithDate(signRequest: URL, secretKey: String, accessKey: String, sessionToken: String,
                             wssRequest: URL, region: String, date:(fullDateTimestamp: String, shortDate: String)) -> URL? {
        var canonicalUri = signRequest.path
        if canonicalUri.isEmpty {
            canonicalUri = slashDelimiter
        }
        let credentialScope = getCredentialScope(shortDate: date.shortDate, region: region, serviceName: awsKinesisVideoKey, requestType: awsRequestTypeKey)

        let queryParams = getQueryParams(accessKey: accessKey, sessionToken: sessionToken, credentialScope: credentialScope, date: date)
        var queryParamsBuilder: [URLQueryItem] = queryParams.queryParamBuilder
        var queryParamsBuilderDict: [String: String] = queryParams.queryParamBuilderDict

        //Adding queryParams from the signRequest's query.
        if signRequest.query != nil {
            let queryParams = signRequest.query!
            let queryParamArray = queryParams.components(separatedBy: ampersandDelimiter)

            for param in queryParamArray {
                if let index = param.firstIndex(of: "=") {
                    let nextIndex = param.index(after: index)
                    queryParamsBuilderDict.updateValue(String(param[nextIndex...]).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!, forKey: String(param[..<index]))
                    queryParamsBuilder.append(URLQueryItem(name: String(param[..<index].addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!), value: String(param[nextIndex...])))
                }
            }
        } else {
            print("Error: Missing channel ARN.")
        }

        let canonicalQuerystring = getCanonicalQueryString(queryParamBuilderDict: queryParamsBuilderDict)
        let canonicalRequest = getCanonicalRequest(canonicalQuerystring: canonicalQuerystring!, signRequest: signRequest)
        let stringToSign = getStringToSign(fullDateTimeStamp: date.fullDateTimestamp, credentialScope: credentialScope, canonicalRequest: canonicalRequest!)
        let signature = signatureWith(stringToSign: stringToSign, secretAccessKey: secretKey, shortDateString: date.shortDate, awsRegion: region, serviceType: awsKinesisVideoKey)
        return getSignedUrl(wssRequest: wssRequest, queryParamsBuilder: queryParamsBuilder, canonicalUri: canonicalUri, signature: signature!)

    }
}
