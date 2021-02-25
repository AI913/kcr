//
//  ActionEntryConfigurationContainerViewController.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/25.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit

class ActionEntryConfigurationContainerViewController: UIViewController {

    // MARK: - Variable
    var viewData: MainViewData.Robot!
    var initialHeight: CGFloat = 0

    func inject(viewData: MainViewData.Robot) {
        self.viewData = viewData
    }

    func set(height: CGFloat) {
        initialHeight = height
    }
}
