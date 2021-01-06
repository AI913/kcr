//
//  MailVerificationConfirmViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2019/12/26.
//  Copyright © 2019 Kento Tatsumi. All rights reserved.
//

import UIKit

/// MailVerificationConfirmViewControllerProtocol
/// @mockable
protocol MailVerificationConfirmViewControllerProtocol: class {
    /// Viewを閉じる
    func dismiss()
    /// アラート表示
    /// - Parameter message: メッセージ
    func showAlert(_ message: String)
    /// エラーアラート表示
    /// - Parameter message: メッセージ
    func showErrorAlert(_ message: String)
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// 処理中変更通知
    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool)
    /// Complete画面へ遷移
    func transitionToCompleteScreen()
}

class MailVerificationConfirmViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var confirmationCodeTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var resendButton: UIButton!

    // MARK: - Variable
    var viewData: AuthenticationViewData!
    var presenter: MailVerificationConfirmPresenterProtocol!
    var togglePasswordVisibilityButton: UIButton! {
        didSet {
            togglePasswordVisibilityButton?.tintColor = .secondaryLabel
            togglePasswordVisibilityButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
            togglePasswordVisibilityButton?.frame = CGRect(x: CGFloat(self.passwordTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
            togglePasswordVisibilityButton?.addTarget(self, action: #selector(self.touchUpInsideTogglePasswordVisibilityButton(_:)), for: .touchUpInside)
        }
    }

    private var passwordVisibility: Bool! {
        didSet {
            let iconName = self.passwordVisibility ? "eye.fill" : "eye.slash.fill"
            togglePasswordVisibilityButton?.setImage(UIImage(systemName: iconName), for: .normal)
            passwordTextField?.isSecureTextEntry = !passwordVisibility
        }
    }

    private var processing: Bool! {
        didSet {
            confirmationCodeTextField?.isEnabled = !processing
            passwordTextField?.isEnabled = !processing
            updateButton?.isEnabled = !processing && (presenter?.isEnabledUpdateButton ?? false)
            resendButton?.isEnabled = !processing
            togglePasswordVisibilityButton?.isEnabled = !processing
        }
    }

    func inject(viewData: AuthenticationViewData) {
        self.viewData = viewData
        presenter = AuthenticationBuilder.MailVerificationConfirm().build(vc: self, viewData: viewData)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        setSwipeBack()
        togglePasswordVisibilityButton = UIButton(type: .custom)
        passwordTextField.rightView = togglePasswordVisibilityButton
        passwordTextField.rightViewMode = .always
        passwordVisibility = false
        updateButton?.isEnabled = presenter?.isEnabledUpdateButton ?? false
    }
}

// MARK: - View Controller Event
extension MailVerificationConfirmViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - Action
extension MailVerificationConfirmViewController {

    @IBAction private func touchUpInsideUpdateButton(_ sender: UIButton) {
        presenter?.tapUpdateButton()
    }

    @IBAction private func touchUpInsideResendButton(_ sender: UIButton) {
        presenter?.tapResendButton()
    }

    @IBAction private func editingChangedConfirmationCodeTextField(_ sender: UITextField) {
        presenter?.changedConfirmationCodeTextField(sender.text)
        updateButton?.isEnabled = presenter?.isEnabledUpdateButton ?? false
    }

    @IBAction private func editingChangedPasswordTextField(_ sender: UITextField) {
        presenter?.changedPasswordTextField(sender.text)
        updateButton?.isEnabled = presenter?.isEnabledUpdateButton ?? false
    }

    @IBAction private func didEndOnExitConfirmationCodeTextField(_ sender: UITextField) {
        passwordTextField.becomeFirstResponder()
    }

    @IBAction private func didEndOnExitPasswordTextField(_ sender: UITextField) {
        sender.endEditing(true)
    }

    @objc
    private func touchUpInsideTogglePasswordVisibilityButton(_ sender: UIButton) {
        passwordVisibility = !passwordVisibility
    }
}

// MARK: - Interface Function
extension MailVerificationConfirmViewController: MailVerificationConfirmViewControllerProtocol {

    func dismiss() {
        dismiss(animated: true)
    }

    func showAlert(_ message: String) {
        presentAlert("Info", message)
    }

    func showErrorAlert(_ message: String) {
        presentAlert("Error", message)
    }

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    func changedProcessing(_ isProcessing: Bool) {
        processing = isProcessing
    }

    func transitionToCompleteScreen() {
        self.perform(segue: StoryboardSegue.PasswordAuthentication.showMailVerificationComplete)
    }
}
