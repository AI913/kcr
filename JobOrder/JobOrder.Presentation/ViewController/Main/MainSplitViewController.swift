//
//  MainSplitViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/15.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class MainSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        for vc in self.viewControllers {
            if let navigationController = vc as? UINavigationController {
                for vc in navigationController.viewControllers {
                    _ = vc.view
                }
            }
        }
        self.preferredDisplayMode = .allVisible
        self.delegate = self
    }
}

// MARK: - UISplitViewControllerDelegate
extension MainSplitViewController: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {

        guard let navigationController = secondaryViewController as? UINavigationController else {
            return false
        }

        if let vc = navigationController.topViewController as? JobDetailViewController {
            return vc.viewData == nil
        } else if let vc = navigationController.topViewController as? RobotDetailViewController {
            return vc.viewData == nil
        } else {
            return false
        }
    }
}
