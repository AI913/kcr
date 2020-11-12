//
//  PasswordAuthenticationNavigationController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/03/31.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class PasswordAuthenticationNavigationController: UINavigationController {

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.beginAppearanceTransition(true, animated: animated)
        presentingViewController?.endAppearanceTransition()
    }
}

// MARK: - Interface Function
extension PasswordAuthenticationNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        for vc in self.viewControllers {
            self.navigationBar.isHidden = isHiddenNavigationBar(vc)
        }
    }
}

// MARK: - Private Function
extension PasswordAuthenticationNavigationController {

    private func isHiddenNavigationBar(_ vc: UIViewController) -> Bool {
        return (vc as? PasswordAuthenticationViewController) != nil
    }
}
