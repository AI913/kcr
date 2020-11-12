//
//  RobotDetailContainerViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/20.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class RobotDetailContainerViewController: UIViewController {

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
