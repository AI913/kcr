//
//  OrderEntryConfirmViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/09.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// OrderEntryConfirmViewControllerProtocol
/// @mockable
protocol OrderEntryConfirmViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// 処理中変更通知
    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool)
    /// Complete画面へ遷移
    func transitionToCompleteScreen()
}

class OrderEntryConfirmViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var jobValueLabel: UILabel!
    @IBOutlet weak var robotsValueLabel: UILabel!
    @IBOutlet weak var startConditionValueLabel: UILabel!
    @IBOutlet weak var exitConditionValueLabel: UILabel!
    @IBOutlet weak var numberOfRunsValueLabel: UILabel!
    @IBOutlet weak var remarksValueLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!

    // MARK: - Variable
    var viewData: OrderEntryViewData!
    var presenter: OrderEntryConfirmPresenterProtocol!
    private var processing: Bool! {
        didSet {
            sendButton?.isEnabled = !processing
        }
    }

    func inject(viewData: OrderEntryViewData) {
        self.viewData = viewData
        presenter = OrderEntryBuilder.Confirm().build(vc: self, viewData: viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwipeBack()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        jobValueLabel?.text = presenter?.job
        robotsValueLabel?.text = toLabelText(presenter?.robots)
        startConditionValueLabel?.text = toLabelText(presenter?.startCondition)
        exitConditionValueLabel?.text = toLabelText(presenter?.exitCondition)
        numberOfRunsValueLabel?.text = toLabelText(presenter?.numberOfRuns)
        remarksValueLabel?.text = toLabelText(presenter?.remarks)
        remarksValueLabel?.isEnabled = hasLabelText(presenter?.remarks)
    }
}

// MARK: - Action
extension OrderEntryConfirmViewController {

    @IBAction private func touchUpInsideSendButton(_ sender: UIButton) {
        presenter?.tapSendButton()
    }
}

// MARK: - Protocol Function
extension OrderEntryConfirmViewController: OrderEntryConfirmViewControllerProtocol {

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    func changedProcessing(_ isProcessing: Bool) {
        processing = isProcessing
    }

    func transitionToCompleteScreen() {
        self.perform(segue: StoryboardSegue.OrderEntry.showComplete)
    }
}
