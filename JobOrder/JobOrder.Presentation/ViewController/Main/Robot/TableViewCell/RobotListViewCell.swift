//
//  RobotListViewCell.swift
//  JobOrder
//
//  Created by Kento Tatsumi on 2020/01/07.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class RobotListViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet private weak var displayNameLabel: UILabel!
    @IBOutlet private weak var typeAndClassificationLabel: UILabel!
    @IBOutlet private weak var stateValueLabel: UILabel!
    @IBOutlet private weak var stateImageView: UIImageView!

    // MARK: - Constant
    static let identifier: String = "RobotListViewCell"

    // MARK: - Variable
    private var presenter: RobotListPresenterProtocol!

    func inject(presenter: RobotListPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - Function
    func setRow(_ indexPath: IndexPath) {

        let mutableAttributedString = NSMutableAttributedString()

        if let displayName = presenter?.displayName(indexPath.row) {
            mutableAttributedString.append(NSAttributedString(string: displayName, attributes: [
                .foregroundColor: displayNameLabel.textColor!,
                .font: displayNameLabel.font!
            ]))
        }

        if let useCloudServer = presenter?.useCloudServer, useCloudServer == false {
            mutableAttributedString.append(NSAttributedString(string: " (\(toLabelText(presenter?.serverUrl).localized)) ", attributes: [
                .foregroundColor: UIColor.secondaryLabel,
                .font: UIFont.systemFont(ofSize: 14.0)
            ]))
        }

        displayNameLabel.attributedText = mutableAttributedString
        stateValueLabel.text = presenter?.stateName(indexPath.row)
        stateImageView.image = UIImage(systemName: presenter?.stateImageName(indexPath.row) ?? "")
        stateImageView.tintColor = presenter?.stateTintColor(indexPath.row)
        typeAndClassificationLabel.text = presenter?.typeName(indexPath.row)
    }
}
