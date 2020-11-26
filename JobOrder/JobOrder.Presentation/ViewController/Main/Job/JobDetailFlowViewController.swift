//
//  JobDetailFlowViewController.swift
//  JobOrder.Presentation
//
//  Created by 藤井一暢 on 2020/11/16.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// JobDetailFlowViewControllerProtocol
/// @mockable
protocol JobDetailFlowViewControllerProtocol: class {}

class JobDetailFlowViewController: JobDetailContainerViewController {
    // MARK: - Variable
    var presenter: JobDetailFlowPresenterProtocol!

    override func inject(viewData: MainViewData.Job) {
        super.inject(viewData: viewData)
        presenter = MainBuilder.JobDetailFlow().build(vc: self, viewData: viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = self.view.subviews.reduce(0) {
            $0 + $1.frame.height
        }
        preferredContentSize.height = max(height, initialHeight)
    }
}

extension JobDetailFlowViewController: JobDetailFlowViewControllerProtocol {}
