//
//  PasswordAuthenticationViewController.swift
//  JobOrder.Presentation
//
//  Created by Kento Tatsumi on 2020/03/05.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

/// PasswordAuthenticationViewControllerProtocol
/// @mockable
protocol PasswordAuthenticationViewControllerProtocol: class {
    /// Viewを閉じる
    func dismiss()
    /// 生体認証ログインによりViewを閉じる
    func dismissByBiometricsAuthentication()
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// 処理中変更通知
    /// - Parameter isProcessing: 処理状態
    func changedProcessing(_ isProcessing: Bool)
    /// NewPasswordRequired画面へ遷移
    func transitionToNewPasswordRequiredScreen()
    /// ConnectionSettings画面へ遷移
    func transitionToConnectionSettings()
}

class PasswordAuthenticationViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var connectionSettingsButton: UIButton!
    @IBOutlet weak var biometricsAuthenticationButton: UIButton!
    @IBOutlet weak var biometricsAuthenticationLabel: UILabel!
    @IBOutlet weak var passwordResetButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!

    // MARK: - Variable
    var presenter: PasswordAuthenticationPresenterProtocol!

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
            identifierTextField?.isEnabled = !processing
            passwordTextField?.isEnabled = !processing
            connectionSettingsButton?.isEnabled = !processing
            passwordResetButton?.isEnabled = !processing
            togglePasswordVisibilityButton?.isEnabled = !processing
            signInButton?.isEnabled = !processing && (presenter?.isEnabledSignInButton ?? false)
            biometricsAuthenticationButton?.isEnabled = !processing && (presenter?.isEnabledBiometricsButton ?? false)
        }
    }

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = AuthenticationBuilder.PasswordAuthentication().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        togglePasswordVisibilityButton = UIButton(type: .custom)
        passwordTextField?.rightView = togglePasswordVisibilityButton
        passwordTextField?.rightViewMode = .always
        passwordVisibility = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let presenter = presenter else { return }

        if identifierTextField?.text == "" {
            if presenter.isRestoredIdentifier, let username = presenter.username {
                identifierTextField?.text = username
            }
        }
        passwordTextField?.text = ""

        presenter.changedIdentifierTextField(identifierTextField?.text)
        presenter.changedPasswordTextField(passwordTextField?.text)
        biometricsAuthenticationButton?.isHidden = !presenter.isEnabledBiometricsButton
        biometricsAuthenticationLabel?.isHidden = !presenter.isEnabledBiometricsButton
        signInButton?.isEnabled = presenter.isEnabledSignInButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
    }
}

// MARK: - View Controller Event
extension PasswordAuthenticationViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - Action
extension PasswordAuthenticationViewController {

    @IBAction private func touchUpInsideSignInButton(_ sender: UIButton) {
        presenter?.tapSignInButton()
    }

    @IBAction private func editingChangedIdentifierTextField(_ sender: UITextField) {
        presenter?.changedIdentifierTextField(sender.text)
        signInButton?.isEnabled = presenter?.isEnabledSignInButton ?? false
    }

    @IBAction private func editingChangedPasswordTextField(_ sender: UITextField) {
        presenter?.changedPasswordTextField(sender.text)
        signInButton?.isEnabled = presenter?.isEnabledSignInButton ?? false
    }

    @IBAction private func didEndOnExitIdentifierTextField(_ sender: UITextField) {
        passwordTextField.becomeFirstResponder()
    }

    @IBAction private func didEndOnExitPasswordTextField(_ sender: UITextField) {
        sender.endEditing(true)
    }

    @IBAction private func touchUpInsideBiometricsAuthenticationButton(_ sender: UIButton) {
        presenter?.tapBiometricsAuthenticationButton()
    }

    @objc
    private func touchUpInsideTogglePasswordVisibilityButton(_ sender: UIButton) {
        passwordVisibility = !passwordVisibility
    }
}

// MARK: - Interface Function
extension PasswordAuthenticationViewController: PasswordAuthenticationViewControllerProtocol {

    func dismiss() {
        dismiss(animated: true)
    }

    func dismissByBiometricsAuthentication() {
        dismiss(animated: true)

        self.parent?.presentingViewController?.children.forEach {
            if let vc = $0 as? MainTabBarController {
                vc.viewWillAppearByBiometricsAuthentication()
            }
        }
    }

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    func changedProcessing(_ isProcessing: Bool) {
        processing = isProcessing
    }

    func transitionToNewPasswordRequiredScreen() {
        self.perform(segue: StoryboardSegue.PasswordAuthentication.showNewPasswordRequired)
    }

    func transitionToConnectionSettings() {
        self.perform(segue: StoryboardSegue.PasswordAuthentication.showConnectionSettings)
    }
}
