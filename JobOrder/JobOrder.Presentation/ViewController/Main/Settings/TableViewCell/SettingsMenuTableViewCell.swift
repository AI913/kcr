//
//  SettingsMenuTableViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2019/12/25.
//  Copyright © 2019 Kento Tatsumi. All rights reserved.
//

import UIKit

class SettingsMenuTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var remarksLabel: UILabel!

    // MARK: - Variable
    var identifier: String { "SettingsMenuTableViewCell" }
    fileprivate var presenter: SettingsPresenterProtocol!
    fileprivate var data: SettingsViewData.SettingsMenu! {
        didSet { didSetData() }
    }
    fileprivate var remarks: String? {
        didSet { didSetRemarks() }
    }

    func inject(presenter: SettingsPresenterProtocol, viewData: SettingsViewData.SettingsMenu) {
        self.presenter = presenter
        self.data = viewData
    }

    // MARK: - Function
    func didSetData() {

        guard let data = self.data else {
            self.accessoryType = .none
            titleLabel.text = nil
            iconImageView.image = nil
            remarksLabel.isHidden = true
            remarksLabel.text = nil
            return
        }

        self.accessoryType = data.accessory
        titleLabel.text = data.displayName
        iconImageView.image = data.icon
        remarks = data.remarks

        switch data {
        case .syncData:
            remarks = presenter.syncedDate
        default: break
        }
    }

    // MARK: - Private Function
    private func didSetRemarks() {
        remarksLabel.text = remarks?.localized
        remarksLabel.isHidden = remarks == nil
    }
}

class SettingsMenuTableViewSwitchCell: SettingsMenuTableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var switchView: UISwitch!

    // MARK: - Constants
    override var identifier: String { "SettingsMenuTableViewSwitchCell" }

    // MARK: - Function
    override func didSetData() {
        super.didSetData()
        selectionStyle = .none

        switch data {
        case .restoreIdentifier:
            switchView.isOn = presenter?.isRestoredIdentifier ?? false
        case .biometricsAuthentication:
            switchView.isOn = presenter?.isUsedBiometricsAuthentication ?? false
            let biometrics = presenter?.canUseBiometricsWithErrorDescription ?? (false, nil)
            switchView.isEnabled = biometrics.0
            remarks = biometrics.1
        default: break
        }
    }

    // MARK: - Action
    @IBAction func onChangedSwitch(_ sender: UISwitch) {

        switch data {
        case .restoreIdentifier:
            presenter?.isRestoredIdentifier = sender.isOn
        case .biometricsAuthentication:
            presenter?.isUsedBiometricsAuthentication = sender.isOn
        default: break
        }
    }
}
