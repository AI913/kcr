//
//  RobotDetailSystemViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/20.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit
import Charts

/// RobotDetailSystemViewControllerProtocol
/// @mockable
protocol RobotDetailSystemViewControllerProtocol: class {}

class RobotDetailSystemViewController: RobotDetailContainerViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var operatingSystemLabel: UILabel!
    @IBOutlet weak var middlewareLabel: UILabel!
    @IBOutlet weak var systemVersionLabel: UILabel!
    @IBOutlet weak var storageBarChartView: BarChartView!

    // MARK: - Variable
    var presenter: RobotDetailSystemPresenterProtocol!

    override func inject(viewData: MainViewData.Robot) {
        super.inject(viewData: viewData)
        presenter = MainBuilder.RobotDetailSystem().build(vc: self, viewData: viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        operatingSystemLabel?.text = presenter?.operatingSystem
        middlewareLabel?.text = presenter?.middleware
        systemVersionLabel?.text = presenter?.systemVersion
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = self.view.subviews.reduce(0) {
            $0 + $1.frame.height
        }
        preferredContentSize.height = max(height, initialHeight)
    }
}

extension RobotDetailSystemViewController: RobotDetailSystemViewControllerProtocol {}
