//
//  PageObject.swift
//  JobOrderUITests
//
//  Created by Yu Suzuki on 2020/06/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import XCTest

protocol PageObject: PageObjectAssertion, PageObjectWaitable {
    var app: XCUIApplication { get }
    var view: XCUIElement { get }

    init(application: XCUIApplication)
}

protocol PageObjectWaitable {
    func waitForExistence(timeout: TimeInterval) -> Bool
}

extension PageObjectWaitable where Self: PageObject {
    func waitForExistence(timeout: TimeInterval = 3) -> Bool {
        return view.waitForExistence(timeout: timeout)
    }
}

extension PageObject {
    func waitExists<T>(_ klass: T.Type, timeout: TimeInterval = 3) -> T {
        XCTAssert(waitForExistence(timeout: timeout))
        return self as! T
    }
}

protocol PageObjectAssertion {
    var existsPage: Bool { get }
}
