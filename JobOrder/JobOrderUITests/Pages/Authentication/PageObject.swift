//
//  PageObject.swift
//  JobOrderUITests
//
//  Created by Yu Suzuki on 2020/06/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

protocol PageObject: PageObjectAssertion {
    var app: XCUIApplication { get }
    var view: XCUIElement { get }

    init(application: XCUIApplication)
}

extension PageObject {
    func waitExists<T>(_ context: XCTestCase, _ klass: T.Type, timeout: TimeInterval = 3) -> T {
        //sleep(timeout)
        context.wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: view)], timeout: timeout)
        return self as! T
    }
}

protocol PageObjectAssertion {
    var existsPage: Bool { get }
}
