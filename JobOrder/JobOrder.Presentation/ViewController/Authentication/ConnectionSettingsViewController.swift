//
//  ConnectionSettingsViewController.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2019/12/26.
//  Copyright © 2019 Kento Tatsumi. All rights reserved.
//

import UIKit

/// ConnectionSettingsViewControllerProtocol
/// @mockable
protocol ConnectionSettingsViewControllerProtocol: class {
    /// エラーアラート表示
    /// - Parameter error: エラー
    func showErrorAlert(_ error: Error)
    /// 戻る
    func back()
}

class ConnectionSettingsViewController: UIViewController {

    // MARK: - Variable
    var presenter: ConnectionSettingsPresenterProtocol!

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = AuthenticationBuilder.ConnectionSettings().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - View Controller Event
extension ConnectionSettingsViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - Action
extension ConnectionSettingsViewController {

    @IBAction private func touchUpInsideResetButton(_ sender: UIButton) {
        presentAlert("Do you want to reset it?", "Please restart the application after resetting.", hasCancel: true) { _ in
            self.presenter?.tapResetButton()
        }
    }
}

// MARK: - Interface Function
extension ConnectionSettingsViewController: ConnectionSettingsViewControllerProtocol {

    func showErrorAlert(_ error: Error) {
        presentAlert(error)
    }

    func back() {
        self.navigationController?.popViewController(animated: true)
    }
}
