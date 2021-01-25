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
