//
//  FakeFactory.swift
//  JobOrder.APITests
//
//  Created by 藤井一暢 on 2021/01/04.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import Foundation
import SwiftCheck

public class FakeFactory {
    public static let shared = FakeFactory()

    public let lowerCaseLetters: Gen<Character> = Gen<Character>.fromElements(in: "a"..."z")
    public let upperCaseLetters: Gen<Character> = Gen<Character>.fromElements(in: "A"..."Z")
    public let numeric: Gen<Character> = Gen<Character>.fromElements(in: "0"..."9")
    public let special: Gen<Character> = Gen<Character>.fromElements(of: ["!", "#", "$", "%", "&", "'", "*", "+", "-", "/", "=", "?", "^", "_", "`", "{", "|", "}", "~", "."])

    public let iso639Codes: Gen<String> = Gen<String>.fromElements(of: Locale.isoLanguageCodes)
    public let iso3166Codes: Gen<String> = Gen<String>.fromElements(of: Locale.isoRegionCodes)

    public var emailGen: Gen<String> {

        let allowedLocalCharacters: Gen<Character> = Gen<Character>.one(of: [
            upperCaseLetters,
            lowerCaseLetters,
            numeric,
            special
        ])

        let localEmail = allowedLocalCharacters
            .proliferateNonEmpty
            .suchThat { $0[$0.index(before: $0.endIndex)] != "." }
            .map { String($0) }

        let hostname = Gen<Character>.one(of: [
            lowerCaseLetters,
            numeric,
            Gen.pure("-")
        ]).proliferateNonEmpty.map { String($0) }

        let tld = lowerCaseLetters
            .proliferateNonEmpty
            .suchThat { $0.count > 1 }
            .map { String($0) }

        return glue([localEmail, Gen.pure("@"), hostname, Gen.pure("."), tld])
    }

    public var localeGen: Gen<String> {
        return glue([iso639Codes, Gen.pure("_"), iso3166Codes])
    }

    public var epochTimeGen: Gen<Int> {
        return Date.arbitrary.map({ Int($0.timeIntervalSince1970 * 1000) })
    }

    public var uuidStringGen: Gen<String> {
        return UUID.arbitrary.map({ $0.uuidString })
    }

    public var httpErrorGen: Gen<(Int, String)> {
        let error4xx: Gen<(Int, String)> = Gen<(Int, String)>.compose { c in
            let code = c.generate(using: Gen<Int>.fromElements(in: 400...499))
            let message = "DEFAULT_\(code)"
            return (code, message)
        }
        let error5xx: Gen<(Int, String)> = Gen<(Int, String)>.compose { c in
            let code = c.generate(using: Gen<Int>.fromElements(in: 500...599))
            let message = "DEFAULT_\(code)"
            return (code, message)
        }

        let errors: [Gen<(Int, String)>] = [
            Gen.pure((403, "ACCESS_DENIED")),
            Gen.pure((500, "API_CONFIGURATION_ERROR")),
            Gen.pure((500, "AUTHORIZER_FAILURE")),
            Gen.pure((500, "AUTHORIZER_CONFIGURATION_ERROR")),
            Gen.pure((400, "BAD_REQUEST_PARAMETERS")),
            Gen.pure((400, "BAD_REQUEST_BODY")),
            error4xx,	// DEFAULT_4XX
            error5xx,	// DEFAULT_5XX
            Gen.pure((403, "EXPIRED_TOKEN")),
            Gen.pure((403, "INVALID_SIGNATURE")),
            Gen.pure((504, "INTEGRATION_FAILURE")),
            Gen.pure((504, "INTEGRATION_TIMEOUT")),
            Gen.pure((403, "INVALID_API_KEY")),
            Gen.pure((403, "MISSING_AUTHENTICATION_TOKEN")),
            Gen.pure((429, "QUOTA_EXCEEDED")),
            Gen.pure((413, "REQUEST_TOO_LARGE")),
            Gen.pure((404, "RESOURCE_NOT_FOUND")),
            Gen.pure((429, "THROTTLED")),
            Gen.pure((401, "UNAUTHORIZED")),
            Gen.pure((415, "UNSUPPORTED_MEDIA_TYPE"))
        ]
        return Gen<(Int, String)>.one(of: errors)
    }

    public var rcsErrorGen: Gen<String> {
        let v1Robots = (1...32).map { String(format: "ir%02d", $0) }
        let v1Tasks = (1...7).map { String(format: "it%02d", $0) }
        let v1Jobs = (1...7).map { String(format: "ij%02d", $0) }
        let v1Action = (1...10).map { String(format: "il%02d", $0) }
        let v1CerRobots = (1...2).map { String(format: "cr%02d", $0) }
        let v1CerTasks = (1...5).map { String(format: "ct%02d", $0) }
        let v1CerAction = (1...2).map { String(format: "cl%02d", $0) }
        let mqtt = ["mr01", "mt01"]
        let dynamo = ["dt01"]
        let v1CerPost = ["ct06"]
        let rcsMethodIDs: [String] = [v1Robots, v1Tasks, v1Jobs, v1Action, v1CerRobots, v1CerTasks, v1CerAction, mqtt, dynamo, v1CerPost].flatMap { $0 }
        let errorCodes = (1...11).map { String(format: "%04d", $0) }
        let detailCodes = (1...10).map { String(format: "%04d", $0) }

        let rcsMethodIDGen: Gen<String> = Gen<String>.fromElements(of: [ rcsMethodIDs, ["zzzz"]].flatMap({ $0 }) )
        let errorCodeGen: Gen<String> = Gen<String>.fromElements(of: [ errorCodes, ["9999"]].flatMap({ $0 }) )
        let detailCodeGen: Gen<String> = Gen<String>.fromElements(of: [ detailCodes, ["9999"]].flatMap({ $0 }) )

        return glue([rcsMethodIDGen, Gen.pure("-"), errorCodeGen, Gen.pure("-"), detailCodeGen])	// "ct02-0001-0003"
    }
}

extension FakeFactory {

    private func glue(_ parts: [Gen<String>]) -> Gen<String> {
        return sequence(parts).map { $0.reduce("", +) }
    }

}

// MARK: -

extension Date: RandomType, Arbitrary {
    public static func randomInRange<G: RandomGeneneratorType>(_ range: (Self, Self), gen: G) -> (Self, G) {
        let (min, max) = range
        let (t, gen2) = Double.randomInRange((min.timeIntervalSince1970, max.timeIntervalSince1970), gen: gen)
        return (Date(timeIntervalSince1970: t), gen2)
    }

    public static var arbitrary: Gen<Self> {
        return Gen.fromElements(in: Date(timeIntervalSince1970: 0)...Date(timeIntervalSince1970: TimeInterval(Int32.max)))
    }
}

extension UUID: Arbitrary {
    public static var arbitrary: Gen<Self> {
        return Gen<Self>.compose { _ in UUID() }
    }
}

extension Data: Arbitrary {
    public static var arbitrary: Gen<Self> {
        let dictionary = Dictionary<String, String>.arbitrary.generate
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
            return Gen<Self>.compose { _ in Data() }
        }
        return Gen<Self>.compose { _ in data }
    }
}
