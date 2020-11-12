//
//  OneOffFunc.swift
//  JobOrder.Utility
//
//  Created by Kento Tatsumi on 2020/03/06.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import Foundation

public class OneOffFunc {

    private(set) public var executed = false

    public init() {}

    public func execute(function: () -> Void) {
        guard !self.executed else {
            return
        }
        function()
        self.executed = true
    }
}
