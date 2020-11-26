//
//  JobDetailContainerViewController.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class JobDetailContainerViewController: UIViewController {

    // MARK: - Variable
    var viewData: MainViewData.Job!
    var initialHeight: CGFloat = 0

    func inject(viewData: MainViewData.Job) {
        self.viewData = viewData
    }

    func set(height: CGFloat) {
        initialHeight = height
    }
}
