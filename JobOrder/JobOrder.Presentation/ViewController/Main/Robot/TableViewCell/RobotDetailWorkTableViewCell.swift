//
//  RobotDetailWorkTaskTableViewCell.swift
//  JobOrder.Presentation
//
//  Created by Yu Suzuki on 2020/04/22.
//  Copyright © 2020 Kento Tatsumi. All rights reserved.
//

import UIKit

class RobotDetailWorkTableViewCell: UITableViewCell {

    // MARK: - Variable
    var identifier = ""
    var presenter: RobotDetailWorkPresenterProtocol!
    var dataset: RobotDetailWorkPresenter.Dataset!

    func inject(presenter: RobotDetailWorkPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: - Function
    func setRow(_ indexPath: IndexPath) {}
}
