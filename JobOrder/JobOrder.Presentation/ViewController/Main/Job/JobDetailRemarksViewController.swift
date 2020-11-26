//
//  JobDetailRemarksViewController.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// JobDetailRemarksViewControllerProtocol
/// @mockable
protocol JobDetailRemarksViewControllerProtocol: class {}

class JobDetailRemarksViewController: JobDetailContainerViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var remarksValueLabel: UILabel!

    // MARK: - Variable
    var presenter: JobDetailRemarksPresenterProtocol!

    override func inject(viewData: MainViewData.Job) {
        super.inject(viewData: viewData)
        presenter = MainBuilder.JobDetailRemarks().build(vc: self, viewData: viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        remarksValueLabel.showSkeleton()
        remarksValueLabel.text = presenter.remarks
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = self.view.subviews.reduce(0) {
            $0 + $1.frame.height
        }
        preferredContentSize.height = max(height, initialHeight)
    }
}

extension JobDetailRemarksViewController: JobDetailRemarksViewControllerProtocol {}
