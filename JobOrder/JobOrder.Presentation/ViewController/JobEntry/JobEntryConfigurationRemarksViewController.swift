//
//  JobEntryConfigurationRemarksViewController.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/24.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit

/// JobEntryConfigurationRemarksViewController
/// @mockable
protocol JobEntryConfigurationRemarksViewControllerProtocol: class {}

class JobEntryConfigurationRemarksViewController: JobEntryConfigurationContainerViewController {

//    // MARK: - IBOutlet
//    @IBOutlet weak var remarksValueLabel: UILabel!

    // MARK: - Variable
    var presenter: JobEntryConfigurationRemarksPresenterProtocol!

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

extension JobEntryConfigurationRemarksViewController: JobEntryConfigurationRemarksViewControllerProtocol {}
