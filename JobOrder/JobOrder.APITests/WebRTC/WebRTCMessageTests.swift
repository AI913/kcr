//
//  WebRTCMessageTests.swift
//  JobOrder.APITests
//
//  Created by Yu Suzuki on 2020/07/27.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest
import WebRTC
@testable import JobOrder_API

class WebRTCMessageTests: XCTestCase {

    var testMessage: WebRTCMessage?

    override func setUp() {
    }

    override func tearDown() {
    }

    func testCreateAnswerMessage() {
        let actualMessage = WebRTCMessage.createAnswerMessage(sdp: testsdp, testRecipientClientId)
        XCTAssertEqual(actualMessage.getAction(), answerAction)
        XCTAssertNotNil(actualMessage.getMessagePayload)
        XCTAssertNotNil(actualMessage.getRecipientClientId)
        XCTAssertEqual(actualMessage.getRecipientClientId(), testRecipientClientId)
    }

    func testCreateOfferMessage() {
        let actualMessage = WebRTCMessage.createOfferMessage(sdp: testsdp, senderClientId: testSenderClientId)
        XCTAssertEqual(actualMessage.getAction(), offerAction)
        XCTAssertNotNil(actualMessage.getMessagePayload)
        XCTAssertNotNil(actualMessage.getSenderClientId)
        XCTAssertEqual(actualMessage.getSenderClientId(), testSenderClientId)
    }

    func testIceCandidates_isMaster() {
        let testRTCIceCandidate = RTCIceCandidate(sdp: testMessagePayload, sdpMLineIndex: 3, sdpMid: testMessagePayload)

        let actualMessage = WebRTCMessage.createIceCandidateMessage(candidate: testRTCIceCandidate, true, recipientClientId: testRecipientClientId, senderClientId: testSenderClientId)
        XCTAssertEqual(actualMessage.getAction(), iceCandidateAction)
        XCTAssertNotNil(actualMessage.getMessagePayload)
        XCTAssertNotNil(actualMessage.getSenderClientId)
        XCTAssertEqual(actualMessage.getSenderClientId(), "") //senderClientId is empty when connected as master
        XCTAssertNotNil(actualMessage.getRecipientClientId)
        XCTAssertEqual(actualMessage.getRecipientClientId(), testRecipientClientId)
    }

    func testIceCandidates_isViewer() {
        let testRTCIceCandidate = RTCIceCandidate(sdp: testMessagePayload, sdpMLineIndex: 3, sdpMid: testMessagePayload)

        let actualMessage = WebRTCMessage.createIceCandidateMessage(candidate: testRTCIceCandidate, false, recipientClientId: testRecipientClientId, senderClientId: testSenderClientId)
        XCTAssertEqual(actualMessage.getAction(), iceCandidateAction)
        XCTAssertNotNil(actualMessage.getMessagePayload)
        XCTAssertNotNil(actualMessage.getSenderClientId)
        XCTAssertEqual(actualMessage.getSenderClientId(), testSenderClientId)
        XCTAssertNotNil(actualMessage.getRecipientClientId)
        XCTAssertEqual(actualMessage.getRecipientClientId(), "") //recipientClient is empty when connected as viewer
    }
}
