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
    /// 戻る
    func back()
}

class ConnectionSettingsViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var spaceTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var useCloudServerSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - Variable
    var presenter: ConnectionSettingsPresenterProtocol!
    private var useCloudServer: Bool! {
        didSet {
            urlTextField?.isEnabled = !useCloudServer
            urlTextField?.backgroundColor = useCloudServer ? .secondarySystemFill : .systemGray6
            urlTextField?.text = useCloudServer ? nil : urlTextField?.text
            presenter?.changedServerUrlTextField(urlTextField.text)
            saveButton?.isEnabled = presenter?.isEnabledSaveButton ?? false
            spaceTextField?.returnKeyType = useCloudServer ? .next : .done
        }
    }

    // MARK: - Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = AuthenticationBuilder.ConnectionSettings().build(vc: self)
    }

    // MARK: - Override function (view controller lifecycle)
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let isRegistered = presenter?.isRegisteredSpace, isRegistered else {
            self.isModalInPresentation = true
            self.navigationItem.hidesBackButton = true
            return
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let isRegistered = presenter?.isRegisteredSpace, isRegistered {
            spaceTextField?.text = presenter?.registeredSpaceName
            urlTextField?.text = presenter?.registeredServerUrl
            useCloudServerSwitch?.setOn(presenter?.registeredUseCloudServer ?? false, animated: false)
        } else {
            spaceTextField?.text = nil
            useCloudServerSwitch?.isOn = true
            urlTextField?.text = nil
            presenter?.changedUseCloudServerSwitch(true)
        }
        useCloudServer = useCloudServerSwitch?.isOn
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

    // FIXME: - Warning output console by calling this method.
    @IBAction private func valueChangedUseCloudServerSwitch(_ sender: UISwitch) {
        presenter?.changedUseCloudServerSwitch(sender.isOn)
        saveButton?.isEnabled = presenter?.isEnabledSaveButton ?? false
        useCloudServer = sender.isOn
    }

    @IBAction private func touchUpInsideSaveButton(_ sender: UIButton) {
        presenter?.tapSaveButton()
    }

    @IBAction private func editingChangedSpaceTextField(_ sender: UITextField) {
        presenter?.changedSpaceNameTextField(sender.text)
        saveButton?.isEnabled = presenter?.isEnabledSaveButton ?? false
    }

    @IBAction private func editingChangedUrlTextField(_ sender: UITextField) {
        presenter?.changedServerUrlTextField(sender.text)
        saveButton?.isEnabled = presenter?.isEnabledSaveButton ?? false
    }

    @IBAction private func spaceTextFieldDidEndOnExit(_ sender: UITextField) {
        if urlTextField.isEnabled {
            urlTextField?.becomeFirstResponder()
        } else {
            sender.endEditing(true)
        }
    }

    @IBAction private func urlTextFieldDidEndOnExit(_ sender: UITextField) {
        sender.endEditing(true)
    }
}

// MARK: - Interface Function
extension ConnectionSettingsViewController: ConnectionSettingsViewControllerProtocol {

    func back() {
        self.navigationController?.popViewController(animated: true)
    }
}
