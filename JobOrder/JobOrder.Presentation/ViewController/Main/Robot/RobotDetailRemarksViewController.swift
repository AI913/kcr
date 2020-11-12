//
//  RobotDetailRemarksViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/20.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// RobotDetailRemarksViewControllerProtocol
/// @mockable
protocol RobotDetailRemarksViewControllerProtocol: class {}

class RobotDetailRemarksViewController: RobotDetailContainerViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var remarksValueLabel: UILabel!

    // MARK: - Variable
    var presenter: RobotDetailRemarksPresenterProtocol!

    override func inject(viewData: MainViewData.Robot) {
        super.inject(viewData: viewData)
        presenter = MainBuilder.RobotDetailRemarks().build(vc: self, viewData: viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        remarksValueLabel?.showSkeleton()
        remarksValueLabel?.text = presenter?.remarks
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = self.view.subviews.reduce(0) {
            $0 + $1.frame.height
        }
        preferredContentSize.height = max(height, initialHeight)
    }
}

extension RobotDetailRemarksViewController: RobotDetailRemarksViewControllerProtocol {}
