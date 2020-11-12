//
//  KVSSignerTests.swift
//  JobOrder.APITests
//
//  Created by Yu Suzuki on 2020/07/27.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
@testable import JobOrder_API

class KVSSignerTests: XCTestCase {

    var shortDate: String?
    var fullDate: String?
    var region: String?
    var serviceName: String?
    var requestType: String?

    override func setUp() {

        shortDate = "20150830"
        fullDate = "20150830T123600Z"
        region = "us-west-2"
        serviceName = KVSSigner.awsKinesisVideoKey
        requestType = KVSSigner.awsRequestTypeKey
    }

    override func tearDown() {
    }

    func testGetCredentialScope() {
        let expectedCredentialScope = "20150830/us-west-2/kinesisvideo/aws4_request"
        let actualCredentialScope = KVSSigner.getCredentialScope(shortDate: shortDate!, region: region!, serviceName: serviceName!, requestType: requestType!)
        XCTAssertNotNil(actualCredentialScope)
        XCTAssertEqual(expectedCredentialScope, actualCredentialScope)
    }

    func testGetQueryparamsWithSessionToken() {

        let credentialScope = "20150830/us-west-2/kinesisvideo/aws4_request"
        let actualQueryParams = KVSSigner.getQueryParams(accessKey: "ACCESSKEY", sessionToken: "SESSIONTOKEN", credentialScope: credentialScope, date: (fullDateTimestamp: fullDate!, shortDate: shortDate!))
        _ = actualQueryParams.queryParamBuilder
        let actualQueryParamDictionary = actualQueryParams.queryParamBuilderDict
        XCTAssertEqual(actualQueryParams.queryParamBuilder.count, 6)
        XCTAssertEqual(actualQueryParams.queryParamBuilderDict.count, 6)

        // Presence of session token
        XCTAssertTrue(actualQueryParamDictionary.keys.contains(KVSSigner.xAmzSecurityToken))
        // Presence of the other keys
        XCTAssertTrue(actualQueryParamDictionary.keys.contains(KVSSigner.xAmzDate))
        XCTAssertTrue(actualQueryParamDictionary.keys.contains(KVSSigner.xAmzAlgorithm))
        XCTAssertTrue(actualQueryParamDictionary.keys.contains(KVSSigner.xAmzExpiresKey))
        XCTAssertTrue(actualQueryParamDictionary.keys.contains(KVSSigner.xAmzSignedHeaders))
        XCTAssertTrue(actualQueryParamDictionary.keys.contains(KVSSigner.xAmzCredential))
    }

    func testGetQueryparamsWithoutSessionToken() {

        let credentialScope = "20150830/us-west-2/kinesisvideo/aws4_request"
        let actualQueryParams = KVSSigner.getQueryParams(accessKey: "ACCESSKEY", sessionToken: "", credentialScope: credentialScope, date: (fullDateTimestamp: fullDate!, shortDate: shortDate!))
        _ = actualQueryParams.queryParamBuilder
        let actualQueryParamDictionary = actualQueryParams.queryParamBuilderDict
        XCTAssertEqual(actualQueryParams.queryParamBuilder.count, 5)
        XCTAssertEqual(actualQueryParams.queryParamBuilderDict.count, 5)

        // Presence of session token
        XCTAssertTrue(!actualQueryParamDictionary.keys.contains(KVSSigner.xAmzSecurityToken))
        // Presence of the other keys
        XCTAssertTrue(actualQueryParamDictionary.keys.contains(KVSSigner.xAmzDate))
        XCTAssertTrue(actualQueryParamDictionary.keys.contains(KVSSigner.xAmzAlgorithm))
        XCTAssertTrue(actualQueryParamDictionary.keys.contains(KVSSigner.xAmzExpiresKey))
        XCTAssertTrue(actualQueryParamDictionary.keys.contains(KVSSigner.xAmzSignedHeaders))
        XCTAssertTrue(actualQueryParamDictionary.keys.contains(KVSSigner.xAmzCredential))
    }

    func testGetStringToSign() {
        let expectedStringToSign = "AWS4-HMAC-SHA256" + "\n"
            + "20150830T123600Z" + "\n"
            + "20150830/us-west-2/kinesisvideo/aws4_request" + "\n"
            + "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        let credentialScope = "20150830/us-west-2/kinesisvideo/aws4_request"
        let actualStringToSign = KVSSigner.getStringToSign(fullDateTimeStamp: fullDate!, credentialScope: credentialScope, canonicalRequest: "")

        XCTAssertEqual(actualStringToSign, expectedStringToSign)
    }

    func testGetCanonicalQueryString() {
        let credentialScope = "20150830/us-west-2/kinesisvideo/aws4_request"
        let actualQueryParams = KVSSigner.getQueryParams(accessKey: "ACCESSKEY", sessionToken: "", credentialScope: credentialScope, date: (fullDateTimestamp: fullDate!, shortDate: shortDate!))
        _ = actualQueryParams.queryParamBuilder
        let actualQueryParamDictionary = actualQueryParams.queryParamBuilderDict
        XCTAssertEqual(actualQueryParams.queryParamBuilder.count, 5)
        XCTAssertEqual(actualQueryParams.queryParamBuilderDict.count, 5)
        let expectedCanonicalQueryString = "X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ACCESSKEY%2F20150830%2Fus-west-2%2Fkinesisvideo%2Faws4_request&X-Amz-Date=20150830T123600Z&X-Amz-Expires=299&X-Amz-SignedHeaders=host&"
        let actualCanonicalQueryString = KVSSigner.getCanonicalQueryString(queryParamBuilderDict: actualQueryParamDictionary)
        XCTAssertEqual(actualCanonicalQueryString, expectedCanonicalQueryString)
    }

    func testGetSignedUrl() {
        let expectedSignedUrl = "wss://aws.amazon.com/?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ACCESSKEY%2F20150830%2Fus-west-2%2Fkinesisvideo%2Faws4_request&X-Amz-Date=20150830T123600Z&X-Amz-Expires=299&X-Amz-SignedHeaders=host&X-Amz-Signature=signature"
        let canonicalUri = KVSSigner.getCanonicalUri(signRequest: URL(string: "https://aws.amazon.com/")!)!
        let credentialScope = "20150830/us-west-2/kinesisvideo/aws4_request"
        let actualQueryParams = KVSSigner.getQueryParams(accessKey: "ACCESSKEY", sessionToken: "", credentialScope: credentialScope, date: (fullDateTimestamp: fullDate!, shortDate: shortDate!))
        let actualQueryParamsArray = actualQueryParams.queryParamBuilder

        let actualSignedUrl = KVSSigner.getSignedUrl(wssRequest: URL(string: "wss://aws.amazon.com/")!, queryParamsBuilder: actualQueryParamsArray, canonicalUri: canonicalUri, signature: "signature")
        XCTAssertEqual(actualSignedUrl?.absoluteString, expectedSignedUrl)
    }

    func testGetCanonicalUri() {
        let actualGetCanonicalUri = KVSSigner.getCanonicalUri(signRequest: URL(string: "https://aws.amazon.com/")!)!
        XCTAssertEqual(actualGetCanonicalUri, KVSSigner.slashDelimiter)
    }

    func testGetCanonicalHeaders() {
        let expectedCanonicalHeaders = "host:aws.amazon.com\n"
        let actualCanonicalHeaders = KVSSigner.getCanonicalHeaders(signRequest: URL(string: "https://aws.amazon.com/")!)
        XCTAssertEqual(actualCanonicalHeaders, expectedCanonicalHeaders)
    }

    func testGetCanonicalRequest() {
        let canonicalQueryString = "X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ACCESSKEY%2F20150830%2Fus-west-2%2Fkinesisvideo%2Faws4_request&X-Amz-Date=20150830T123600Z&X-Amz-Expires=299&X-Amz-SignedHeaders=host"
        let expectedCanonicalRequest = "GET\n/\nX-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ACCESSKEY%2F20150830%2Fus-west-2%2Fkinesisvideo%2Faws4_request&X-Amz-Date=20150830T123600Z&X-Amz-Expires=299&X-Amz-SignedHeaders=hos\nhost:aws.amazon.com\n\nhost\ne3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        let actualCanonicalRequest = KVSSigner.getCanonicalRequest(canonicalQuerystring: canonicalQueryString, signRequest: URL(string: "https://aws.amazon.com/")!)
        XCTAssertEqual(actualCanonicalRequest, expectedCanonicalRequest)
    }

    func testSignatureWith() {
        let expectedSignature = "36ea0bd92dc0d7817f6491e64612b79334e38ffbea42fac4b07a7c908864c7a0"
        let stringToSign = "AWS4-HMAC-SHA256" + "\n"
            + "20150830T123600Z" + "\n"
            + "20150830/us-west-2/kinesisvideo/aws4_request" + "\n"
            + "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        let actualSignature = KVSSigner.signatureWith(stringToSign: stringToSign, secretAccessKey: "ACCESSKEY", shortDateString: shortDate!, awsRegion: region!, serviceType: KVSSigner.awsKinesisVideoKey)
        XCTAssertEqual(actualSignature, expectedSignature)
    }

    func testISO8601Date() {
        let date = KVSSigner.iso8601()
        XCTAssertNotNil(date.fullDateTimestamp)
        XCTAssertNotNil(date.shortDate)
    }

    func testSignWithDate() {
        let expectedSignUrlString = "wss://aws.amazon.com/QUERY_PARAM?=AWS4Signer&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ACCESSKEY%2F20150830%2Fus-west-2%2Fkinesisvideo%2Faws4_request&X-Amz-Date=20150830T123600Z&X-Amz-Expires=299&X-Amz-SignedHeaders=host&X-Amz-Signature=78f6f06e596e28b20854f0802b219f3ae288576f3044bafd0d3b8e30fc9b48ef"
        let actualSignedUrl = KVSSigner.signWithDate(signRequest: URL(string: "https://aws.amazon.com/QUERY_PARAM?=AWS4Signer")!, secretKey: "secretkey", accessKey: "ACCESSKEY", sessionToken: "", wssRequest: URL(string: "wss://aws.amazon.com/")!, region: region!, date: (fullDateTimestamp: fullDate!, shortDate: shortDate!))
        XCTAssertEqual(actualSignedUrl?.absoluteString, expectedSignUrlString)
    }

}
