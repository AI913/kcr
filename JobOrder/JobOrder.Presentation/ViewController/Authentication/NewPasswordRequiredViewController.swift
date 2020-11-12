//
//  NewPasswordRequiredViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2019/12/26.
//  Copyright © 2019 Kento Tatsumi. All rights reserved.
//

import UIKit

/// NewPasswordRequiredViewControllerProtocol
/// @mockable
protocol NewPasswordRequiredViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// 処理中変更通知
    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool)
    /// PasswordAuthentication画面へ遷移
    func transitionToPasswordAuthenticationScreen()
}

class NewPasswordRequiredViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var updateButton: UIButton!

    // MARK: - Variable
    var presenter: NewPasswordRequiredPresenterProtocol!
    var togglePasswordVisibilityButton: UIButton! {
        didSet {
            togglePasswordVisibilityButton?.tintColor = .secondaryLabel
            togglePasswordVisibilityButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
            togglePasswordVisibilityButton?.frame = CGRect(x: CGFloat(passwordTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
            togglePasswordVisibilityButton?.addTarget(self, action: #selector(touchUpInsideTogglePasswordVisibilityButton(_:)), for: .touchUpInside)
        }
    }

    private var passwordVisibility: Bool! {
        didSet {
            let iconName = passwordVisibility ? "eye.fill" : "eye.slash.fill"
            togglePasswordVisibilityButton?.setImage(UIImage(systemName: iconName), for: .normal)
            passwordTextField?.isSecureTextEntry = !passwordVisibility
        }
    }

    private var processing: Bool! {
        didSet {
            passwordTextField?.isEnabled = !processing
            updateButton?.isEnabled = !processing && (presenter?.isEnabledUpdateButton ?? false)
            togglePasswordVisibilityButton?.isEnabled = !processing
        }
    }

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = AuthenticationBuilder.NewPasswordRequired().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        togglePasswordVisibilityButton = UIButton(type: .custom)
        passwordTextField.rightView = togglePasswordVisibilityButton
        passwordTextField.rightViewMode = .always
        passwordVisibility = false
        updateButton?.isEnabled = presenter?.isEnabledUpdateButton ?? false
    }
}

// MARK: - View Controller Event
extension NewPasswordRequiredViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - Action
extension NewPasswordRequiredViewController {

    @IBAction private func touchUpInsideUpdateButton(_ sender: UIButton) {
        presenter?.tapUpdateButton()
    }

    @IBAction private func editingChangedPasswordTextField(_ sender: UITextField) {
        presenter?.changedPasswordTextField(sender.text)
        updateButton?.isEnabled = presenter?.isEnabledUpdateButton ?? false
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
extension NewPasswordRequiredViewController: NewPasswordRequiredViewControllerProtocol {

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    func changedProcessing(_ isProcessing: Bool) {
        processing = isProcessing
    }

    func transitionToPasswordAuthenticationScreen() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
