//
//  MailVerificationEntryViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2019/12/26.
//  Copyright © 2019 Kento Tatsumi. All rights reserved.
//

import UIKit

/// MailVerificationEntryViewControllerProtocol
/// @mockable
protocol MailVerificationEntryViewControllerProtocol: class {
    /// Viewを閉じる
    func dismiss()
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// 処理中変更通知
    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool)
    /// Confirm画面へ遷移
    func transitionToConfirmScreen()
}

class MailVerificationEntryViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var sendMailButton: UIButton!

    // MARK: - Variable
    var presenter: MailVerificationEntryPresenterProtocol!
    private var processing: Bool! {
        didSet {
            identifierTextField?.isEnabled = !processing
            sendMailButton?.isEnabled = !processing && (presenter?.isEnabledSendButton ?? false)
        }
    }

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = AuthenticationBuilder.MailVerificationEntry().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        sendMailButton?.isEnabled = presenter?.isEnabledSendButton ?? false
    }
}

// MARK: - View Controller Event
extension MailVerificationEntryViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch StoryboardSegue.PasswordAuthentication(segue) {
        case .showMailVerificationConfirm:
            guard let data = presenter?.data else { return }
            (segue.destination as! MailVerificationConfirmViewController).inject(viewData: data)
        default: break
        }
    }
}

// MARK: - Action
extension MailVerificationEntryViewController {

    @IBAction private func touchUpInsideSendMailButton(_ sender: UIButton) {
        presenter?.tapSendButton()
    }

    @IBAction private func editingChangedIdentifierTextField(_ sender: UITextField) {
        presenter?.changedIdentifierTextField(sender.text)
        sendMailButton?.isEnabled = presenter?.isEnabledSendButton ?? false
    }

    @IBAction private func didEndOnExitIdentifierTextField(_ sender: UITextField) {
        sender.endEditing(true)
    }
}

// MARK: - Interface Function
extension MailVerificationEntryViewController: MailVerificationEntryViewControllerProtocol {

    func dismiss() {
        dismiss(animated: true)
    }

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    func changedProcessing(_ isProcessing: Bool) {
        processing = isProcessing
    }

    func transitionToConfirmScreen() {
        self.perform(segue: StoryboardSegue.PasswordAuthentication.showMailVerificationConfirm)
    }
}
