//
//  JobEntryConfirmViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/09/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class JobEntryConfirmViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var jobName: UILabel!
    @IBOutlet private weak var actionLibrary: UILabel!
    @IBOutlet private weak var workbenchLibrary: UILabel!
    @IBOutlet private weak var workLibrary: UILabel!
    @IBOutlet private weak var bottomButton: UIButton!

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Action
extension JobEntryConfirmViewController {

    @IBAction private func touchUpInsideSubmitButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - Private Function
extension JobEntryConfirmViewController {

    private func setup() {
        navigationItem.title = L10n.JobEntryComfirm.title
        jobName?.text = L10n.JobEntryComfirm.jobName
        actionLibrary?.text = L10n.JobEntryComfirm.actionLibrary
        workbenchLibrary?.text = L10n.JobEntryComfirm.workbenchLibrary
        workLibrary?.text = L10n.JobEntryComfirm.workLibrary
        bottomButton?.setTitle(L10n.JobEntryComfirm.bottomButton, for: .normal)
    }
}
