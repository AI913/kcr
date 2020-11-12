//
//  UIViewController.swift
//  JobOrder.Presentation
//
//  Created by Kento Tatsumi on 2020/03/05.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

extension UIViewController {

    public func toLabelText(_ from: String?) -> String {
        guard let from = from, !from.isEmpty else {
            return "N/A"
        }
        return from
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

    public func toRequiredMutableAttributedString(_ from: String?) -> NSMutableAttributedString? {
        guard let from = from, let range = from.range(of: "*") else {
            return nil
        }
        let attrText = NSMutableAttributedString(string: from)
        let neRange = from.toNsRange(range)
        attrText.addAttribute(.foregroundColor, value: UIColor.systemRed, range: neRange)
        return attrText
    }

    public func setSwipeBack() {
        let target = self.navigationController?.value(forKey: "_cachedInteractionController")
        let recognizer = UIPanGestureRecognizer(target: target, action: Selector(("handleNavigationTransition:")))
        self.view.addGestureRecognizer(recognizer)
    }

    public func presentAlert(_ unlocalizedTitle: String, _ unlocalizedMessage: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: unlocalizedTitle.localized, message: unlocalizedMessage.localized, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK".localized, style: .default, handler: handler)
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }

    public func presentAlert(_ error: Error, handler: ((UIAlertAction) -> Void)? = nil) {
        let title: String
        let message: String
        let nsError = error as NSError
        if let type = nsError.userInfo["__type"] as? String {
            title = "Error:" + type
        } else {
            title = "Error"
        }
        if let errorMessage = nsError.userInfo["message"] as? String {
            message = errorMessage
        } else if let errorMessage = nsError.userInfo["NSLocalizedDescription"] as? String {
            message = errorMessage
        } else if let errorMessage = nsError.userInfo["NSLocalizedFailureReason"] as? String {
            message = errorMessage
        } else {
            message = nsError.localizedDescription
        }
        self.presentAlert(title, message, handler: handler)
    }

    public func presentAlert(_ error: Error?, _ defaultMessage: String, handler: ((UIAlertAction) -> Void)? = nil) {
        if let error = error {
            self.presentAlert(error, handler: handler)
            return
        }
        self.presentAlert("Error", defaultMessage, handler: handler)
    }
}
