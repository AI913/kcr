//
//  UIView.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

extension UIView {

    public func toLabelText(_ from: String?) -> String {
        guard let _from = from, !_from.isEmpty else {
            return "N/A"
        }
        return _from
    }

    public func toLabelText(_ from: Int?) -> String {
        guard let from = from else {
            return "N/A"
        }
        return String(from)
    }

    public func hasLabelText(_ from: String?) -> Bool {
        guard let from = from, !from.isEmpty else {
            return false
        }
        return true
    }

    public func hasLabelText(_ from: Int?) -> Bool {
        return from != nil
    }
}
