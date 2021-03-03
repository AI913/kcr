//
//  ActionEntryConfigurationRemarksViewController.swift
//  JobOrder.Presentation
//
//  Created by Frontarc on 2021/02/24.
//  Copyright © 2021 Kento Tatsumi. All rights reserved.
//

import UIKit

/// ActionEntryConfigurationRemarksViewController
/// @mockable
protocol ActionEntryConfigurationRemarksViewControllerProtocol: class {}

class ActionEntryConfigurationRemarksViewController: ActionEntryConfigurationContainerViewController {
    @IBAction func buttonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }

    // MARK: - IBOutlet
    @IBOutlet weak var remarksTextView: UITextView!

    // MARK: - Variable
    var presenter: ActionEntryConfigurationRemarksPresenterProtocol!

    // MARK: - Override function (view controller lifecycle)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        remarksTextView?.showSkeleton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //        resultLabel.font = UIFont.boldSystemFont(ofSize: 22)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = self.view.subviews.reduce(0) {
            $0 + $1.frame.height
        }
        preferredContentSize.height = max(height, initialHeight)
    }
}

extension ActionEntryConfigurationRemarksViewController: ActionEntryConfigurationRemarksViewControllerProtocol {}
