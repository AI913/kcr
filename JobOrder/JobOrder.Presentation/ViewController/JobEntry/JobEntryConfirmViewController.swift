//
//  JobEntryConfirmViewController.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/09/24.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// JobEntryConfirmViewControllerProtocol
/// @mockable
protocol JobEntryConfirmViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// 処理中変更通知
    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool)
    /// Complete画面へ遷移
    func transitionToCompleteScreen()
}

class JobEntryConfirmViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet private weak var jobName: UILabel!
    @IBOutlet private weak var actionLibrary: UILabel!
    @IBOutlet private weak var workbenchLibrary: UILabel!
    @IBOutlet private weak var workLibrary: UILabel!
    @IBOutlet private weak var bottomButton: UIButton!

    // MARK: - Variable
    var presenter: JobEntryConfirmPresenterProtocol!

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
        presenter?.tapSendButton()
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

// MARK: - Protocol Function
//extension JobEntryConfirmViewController: JobEntryConfirmViewControllerProtocol {
//
//    func showErrorAlert(_ error: Error) {
//        presentAlert(error)
//    }

//    func changedProcessing(_ isProcessing: Bool) {
//        processing = isProcessing
//    }
//
//    func transitionToCompleteScreen() {
//        self.perform(segue: StoryboardSegue.JobEntry.showComplete)
//    }
//}
